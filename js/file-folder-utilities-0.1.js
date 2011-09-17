/* File & Folder utilities */

var once = false;

/*
 * The .hover() method binds handlers for both mouseenter and mouseleave events.
 * You can use it to simply apply behavior to an element during the time the mouse is within the element.

 * Calling $(selector).hover(handlerIn, handlerOut) is shorthand for:

 * $(selector).mouseenter(handlerIn).mouseleave(handlerOut);
 */
 
var keep_track = 0;
 
var superMenuIn = function(ev) {
  
  // get the position and width an height of the placeholder element
  var curr_id = ev.currentTarget.id;
  var target = "#"+curr_id;
  document.superFolder.EpageID.value = curr_id.split('-')[2];
  document.superPage.EpageID.value = curr_id.split('-')[2];
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
  $("#file-folder").css( { "left": ((pos.left - ff_width -8) + "px"), "top": ((pos.top + height) + "px") } );
  
  // for debugging purposes, will cease to be
  // $("#custom-stuff").empty();
  // $("#custom-stuff").append(curr_id);
  
  $("#file-folder").show();
  document.superFolder.NewObject.focus();
  
  // 
  $("#file-folder").keyup(function(eventage) {
  	/* alert(eventage.which + " ... " + eventage.keyCode); */
  	// fix toggle glitch!!!
	if (eventage.keyCode == 27) {
		console.log(eventage);
		eventage.stopImmediatePropagation();
		console.log(target);
		$(target).trigger('click');
		$(target).unbind();
		$(target).toggle(superMenuIn, superMenuOut);
		superMenuOut(); // just in case :/
	} 
  });
  
  /*
  window.console && console.log && console.log(ev);
  window.console && console.log && console.log(ev.currentTarget);
  window.console && console.log && console.log(ev.currentTarget.id);
  window.console && console.log && console.log(target);
  */
}

var superMenuOut = function(ev) {
  $("#file-folder").hide();
}