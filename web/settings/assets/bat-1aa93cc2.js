import{_ as r,p as n,k as c,l as p,A as o,L as l,u as m,q as _,x as b}from"./vendor-94ac8c48.js";import"./vendor-sortablejs-dbc23470.js";const f={name:"DeviceDeyeBat",emits:["update:configuration"],props:{configuration:{type:Object,required:!0},deviceId:{default:void 0},componentId:{required:!0}},methods:{updateConfiguration(t,e=void 0){this.$emit("update:configuration",{value:t,object:e})}}},g={class:"device-deye-bat"},v={class:"small"};function h(t,e,a,w,x,i){const s=n("openwb-base-heading"),d=n("openwb-base-number-input");return c(),p("div",g,[o(s,null,{default:l(()=>[m(" Einstellungen für Deye Batteriespeicher "),_("span",v,"(Modul: "+b(t.$options.name)+")",1)]),_:1}),o(d,{title:"Modbus ID","model-value":a.configuration.modbus_id,min:"1",max:"255","onUpdate:modelValue":e[0]||(e[0]=u=>i.updateConfiguration(u,"configuration.modbus_id"))},null,8,["model-value"])])}const D=r(f,[["render",h],["__file","/opt/openWB-dev/openwb-ui-settings/src/components/devices/deye/bat.vue"]]);export{D as default};
