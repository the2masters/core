#!/bin/sh

#
# OpenWB-Modul für die Anbindung von SolarView über den integrierten TCP-Server
# Details zur API: https://solarview.info/solarview-fb_Installieren.pdf
#

. /var/www/html/openWB/openwb.conf

# Checks
if [ -z "$solarview_hostname" ]; then
  >&2 echo "Missing required variable 'solarview_hostname'"
  return 1
fi
if [ "${solarview_port}" ]; then
  if [ "$solarview_port" -lt 1 ] || [ "$solarview_port" -gt 65535 ]; then
    >&2 echo "Invalid value '$solarview_port' for variable 'solarview_port'"
    return 1
  fi
fi


request() {
  port="${solarview_port:-15000}"
  timeout="${solarview_timeout:-1}"
  command='00*'

  response=$(echo "$command" | nc -w "$timeout" "$solarview_hostname" "$port")
  return_code="$?"
  if [ "$return_code" -ne 0 ]; then
    >&2 echo "Error: request to SolarView failed. Details: return-code: '$return_code', host: '$solarview_hostname', port: '$port', timeout: '$timeout'"
    return "$return_code"
  fi

  [ "$debug" -ne 0 ] && >&2 echo "Raw response: $response"
  #
  # Format:   {WR,Tag,Monat,Jahr,Stunde,Minute,KDY,KMT,KYR,KT0,PAC,UDC,IDC,UDCB,IDCB,UDCC,IDCC,UL1,IL1,UL2,IL2,UL3,IL3,TKK},Checksum
  # Beispiel: {01,05,09,2019,06,25,0000.0,00038,002574,00018647,00000,037,000.0,000,000.0,000,000.0,227,000.0,00},F
  #
  # Bedeutung (siehe SolarView-Dokumentation):
  #  KDY= Tagesertrag (kWh)
  #  KMT= Monatsertrag (kWh)
  #  KYR= Jahresertrag (kWh)
  #  KT0= Gesamtertrag (kWh)
  #  PAC= Generatorleistung in W
  #  UDC, UDCB, UDCC= Generator-Spannungen in Volt pro MPP-Tracker
  #  IDC, IDCB, IDCC= Generator-Ströme in Ampere pro MPP-Tracker
  #  UL1, IL1= Netzspannung, Netzstrom Phase 1
  #  UL2, IL2= Netzspannung, Netzstrom Phase 2
  #  UL3, IL3= Netzspannung, Netzstrom Phase 3
  #  TKK= Temperatur Wechselrichter

  # Geschweifte Klammern und Checksumme entfernen
  values="${response#*\{}"
  values="${values%\}*}"

  # Werte auslesen und verarbeiten
  local LANG=C
  local IFS=','
  echo "$values" | while read -r WR Tag Monat Jahr Stunde Minute KDY KMT KYR KT0 PAC UDC IDC UDCB IDCB UDCC IDCC UL1 IL1 UL2 IL2 UL3 IL3 TKK
  do

    # Werte formatiert in Variablen speichern
    id="$WR"
    timestamp="$Jahr-$Monat-$Tag $Stunde:$Minute"
    power=$(printf -- '%.0f' "$PAC")
    if [ "$power" -gt 0 ]; then
      power="-$power"
    fi
    energy_day=$(printf "%.1f" "$KDY")
    energy_month=$(printf "%.0f" "$KMT")
    energy_year=$(printf "%.0f" "$KYR")
    energy_total=$(printf "%.0f" "$KT0")
    mpptracker1_voltage=$(printf "%.0f" "$UDC")
    mpptracker1_current=$(printf "%.1f" "$IDC")
    mpptracker2_voltage=$(printf "%.0f" "$UDCB")
    mpptracker2_current=$(printf "%.1f" "$IDCB")
    mpptracker3_voltage=$(printf "%.0f" "$UDCC")
    mpptracker3_current=$(printf "%.1f" "$IDCC")
    grid1_voltage=$(printf "%.0f" "$UL1")
    grid1_current=$(printf "%.1f" "$IL1")
    # Bei einphasigen Wechselrichtern fehlen die Werte von Phase 2 und 3 in der Response.
    # Auf der Variable 'IL2' steht dann die Temperatur und alle nachfolgenden Variablen sind unbelegt
    if [ "$IL2" ]; then
      grid2_voltage=$(printf "%.0f" "$UL2")
      grid2_current=$(printf "%.1f" "$IL2")
      grid3_voltage=$(printf "%.0f" "$UL3")
      grid3_current=$(printf "%.1f" "$IL3")
      temperature=$(printf "%.0f" "$TKK")
    else
      temperature=$(printf "%.0f" "$IL2")
    fi

    if [ "$debug" -ne 0 ]; then
      # Werte ausgeben
      >&2 echo "ID: $id"
      >&2 echo "Zeitpunkt: $timestamp"
      >&2 echo "Temperatur: $temperature °C"
      >&2 echo "Leistung: $power W"
      >&2 echo "Energie:"
      >&2 echo "  Tag:    $energy_day kWh"
      >&2 echo "  Monat:  $energy_month kWh"
      >&2 echo "  Jahr:   $energy_year kWh"
      >&2 echo "  Gesamt: $energy_total kWh"
      >&2 echo "Generator-MPP-Tracker-1"
      >&2 echo "  Spannung: $mpptracker1_voltage V"
      >&2 echo "  Strom:    $mpptracker1_current A"
      >&2 echo "Generator-MPP-Tracker-2"
      >&2 echo "  Spannung: $mpptracker2_voltage V"
      >&2 echo "  Strom:    $mpptracker2_current A"
      >&2 echo "Generator-MPP-Tracker-3"
      >&2 echo "  Spannung: $mpptracker3_voltage V"
      >&2 echo "  Strom:    $mpptracker3_current A"
      >&2 echo "Netz:"
      >&2 echo "  Phase 1:"
      >&2 echo "    Spannung: $grid1_voltage V"
      >&2 echo "    Strom:    $grid1_current A"
      if [ "$grid2_voltage" ] || [ "$grid2_current" ]; then
        >&2 echo "  Phase 2:"
        [ "$grid2_voltage" ] && >&2 echo "    Spannung: $grid2_voltage V"
        [ "$grid2_current" ] && >&2 echo "    Strom:    $grid2_current A"
      fi
      if [ "$grid3_voltage" ] || [ "$grid3_current" ]; then
        >&2 echo "  Phase 3:"
        [ "$grid3_voltage" ] && >&2 echo "    Spannung: $grid3_voltage V"
        [ "$grid3_current" ] && >&2 echo "    Strom:    $grid3_current A"
      fi
    fi

    # Werte speichern
    echo "$power"              >'/var/www/html/openWB/ramdisk/pvwatt'
    echo "$energy_total"        >'/var/www/html/openWB/ramdisk/pvkwhk'
    echo "$energy_day"          >'/var/www/html/openWB/ramdisk/daily_pvkwhk'
    echo "$energy_month"        >'/var/www/html/openWB/ramdisk/monthly_pvkwhk'
    echo "$energy_year"         >'/var/www/html/openWB/ramdisk/yearly_pvkwhk'

    # Aktuelle Leistung an der Aufrufer zurückliefern
    echo "$power"
  done
}

request
