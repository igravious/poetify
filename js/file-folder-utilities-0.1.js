/* File & Folder utilities */

function displayMenu(target_obj)
{
	console.log(target_obj);
	$("#file-folder").position({
	  my: "left top",
	  at: "right bottom",
	  of: target_obj
	});
	$("#file-folder").show();
}

var once = false;

/*
 * The .hover() method binds handlers for both mouseenter and mouseleave events.
 * You can use it to simply apply behavior to an element during the time the mouse is within the element.

 * Calling $(selector).hover(handlerIn, handlerOut) is shorthand for:

 * $(selector).mouseenter(handlerIn).mouseleave(handlerOut);
 */
 
var superMenuIn = function(ev) {
  
  // get the position and width an height of the placeholder element
  var target = "#"+ev.currentTarget.id;
  document.superFolder.EpageID.value = ev.currentTarget.id.split('-')[2];
  document.superPage.EpageID.value = ev.currentTarget.id.split('-')[2];
  var pos = $(target).offset();  
  var width = $(target).width();
  var height = $(target).height();
  
  if (!once) {
  	once = false;
  	ff = $("#file-folder").detach();
  	ff.appendTo('body');
  }
  var ff_width = $("#file-folder").width()
  /* alert ("target " + target + " t pos.left " + pos.left + " t pos.top " + pos.top + " t width " + width + " ff width " + ff_width); */
  
  // show the menu to the left and below the placeholder
  $("#file-folder").css( { "left": ((pos.left - ff_width) + "px"), "top": ((pos.top + height) + "px") } );
  
  // for debugging purposes, will cease to be
  $("#custom-stuff").empty();
  $("#custom-stuff").append(ev.currentTarget.id);
  
  // 
  $("#file-folder").keyup(function(eventage) {
  	/* alert(eventage.which + " ... " + eventage.keyCode); */
  	// fix toggle glitch!!!
	if (eventage.keyCode == 27) { superMenuOut(); } 
});
  $("#file-folder").show();
   document.superFolder.NewObject.focus();
  /* console.log(ev);
  console.log(ev.currentTarget);
  console.log(ev.currentTarget.id);
  console.log(target); */
}

var superMenuOut = function(ev) {
  $("#file-folder").hide();
}