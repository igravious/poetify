/* dropshadow */

function dropShadow(shadow,shade,offset,type){

 var color = [getStyle(shadow,"background-color"),getStyle(shadow,"color"),shade];
 var container = (type=="box") ? document.createElement("div") : document.createElement("span");
 var els = [container,shadow];
 var content = shadow.childNodes;

 switch(type){
   case "box":
    container.appendChild(shadow.cloneNode(true));
    for(x=0;content.length>x;x++){
     shadow.removeChild(shadow.childNodes[x]);
    }	
    for(x=0;els.length>x;x++){
     els[x].style.color = color[1];
     els[x].style.position = "relative";
     if(x==0){
      els[x].style.width = getStyle(shadow,"width");
      els[x].style.backgroundColor = color[0];
     } else {	
      els[x].style.margin = offset[0]+"px "+offset[1]+"px";
      els[x].style.backgroundColor = color[2];
     }
    }
    break;
   case "text":	
    for(x=0;content.length>x;x++){
     deep = (content[x].childNodes) ? true : false;
     container.appendChild(content[x].cloneNode(deep));
    }
    for(x=0;els.length>x;x++){
     els[x].style.position = (x==0) ? "absolute" : "relative";
     els[x].style.color = color[x+1];    
    }
    break;
 }

 for(x=0;els.length>x;x++){
   els[x].style.top = (x==0) ? (offset[0]*-1)+"px" : offset[0]+"px";
   els[x].style.left = (x==0) ? (offset[1]*-1)+"px" : offset[1]+"px";
 }
 shadow.appendChild(container);


 function getStyle(obj,style){
   if(obj.currentStyle){
    return obj.currentStyle[style];
   } else if(window.getComputedStyle) {
    return document.defaultView.getComputedStyle(obj,null).getPropertyValue(style);
   }	
 }
}