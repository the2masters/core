import{_ as l,q as n,k as p,l as c,B as a,M as m,x as _,u as f,y as b}from"./vendor-f0f38b48.js";import"./vendor-sortablejs-cbf37f8f.js";const g={name:"DeviceSolarmax",emits:["update:configuration"],props:{configuration:{type:Object,required:!0},deviceId:{default:void 0}},methods:{updateConfiguration(o,e=void 0){this.$emit("update:configuration",{value:o,object:e})}}},v={class:"device-solarmax"},x={class:"small"};function w(o,e,i,h,B,s){const u=n("openwb-base-heading"),d=n("openwb-base-text-input"),r=n("openwb-base-number-input");return p(),c("div",v,[a(u,null,{default:m(()=>[_(" Einstellungen für Solarmax "),f("span",x,"(Modul: "+b(o.$options.name)+")",1)]),_:1}),a(d,{title:"IP oder Hostname",subtype:"host",required:"","model-value":i.configuration.ip_address,"onUpdate:modelValue":e[0]||(e[0]=t=>s.updateConfiguration(t,"configuration.ip_address"))},null,8,["model-value"]),a(r,{title:"Port",required:"",min:1,max:65535,"model-value":i.configuration.port,"onUpdate:modelValue":e[1]||(e[1]=t=>s.updateConfiguration(t,"configuration.port"))},null,8,["model-value"])])}const q=l(g,[["render",w],["__file","/opt/openWB-dev/openwb-ui-settings/src/components/devices/solarmax/device.vue"]]);export{q as default};
