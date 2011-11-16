var $, label_array;

/* File & Folder utilities */

var once = false;

/*
 * The .hover() method binds handlers for both mouseenter and mouseleave events.
 * You can use it to simply apply behavior to an element during the time the mouse is within the element.

 * Calling $(selector).hover(handlerIn, handlerOut) is shorthand for:

 * $(selector).mouseenter(handlerIn).mouseleave(handlerOut);
 */

var keep_track = 0;

var superMenuOut = function () {
	'use strict';
	//$("#file-folder").hide();
	$("#file-folder").dialog('close')
};

var superMenuIn = function (ev) {
	'use strict';

	// get the position and width an height of the placeholder element
	var curr_id = ev.currentTarget.id, target = "#" + curr_id, val = curr_id.split('-')[2], pos, width, height, ff, ff_width;

	if (val === undefined) {
		$(document.superDelete).hide();
		$(document.superRename).hide();
		console.log('has_a_trash');console.log(has_a_trash);
		if (has_a_trash === "yes") {
			$(document.superTrash).show();
		} else {
			$(document.superTrash).hide();
		}
	} else {
		document.superRename.EpageID.value = val;
		document.superDelete.EpageID.value = val;
		$('#delete_me').html(label_array[val]);
		$(document.superRename).show();
		$(document.superDelete).show();
		$(document.superTrash).hide();
	}

	document.superFolder.EpageID.value = val;
	document.superPage.EpageID.value = val;
	pos = $(target).offset();
	width = $(target).width();
	height = $(target).height();

	if (!once) {
		once = false;
		//ff = $("#file-folder").detach();
		//ff.appendTo('body');
		$('#file-folder').dialog({ autoOpen: false })
	}

	//ff_width = $("#file-folder").width();
	/* alert ("target " + target + " t pos.left " + pos.left + " t pos.top " + pos.top + " t width " + width + " ff width " + ff_width); */

	// show the menu to the left and below the placeholder
	//$("#file-folder").css({ "left": ((pos.left - ff_width - 8) + "px"), "top": ((pos.top + height) + "px") });

	// for debugging purposes, will cease to be
	// $("#custom-stuff").empty();
	// $("#custom-stuff").append(curr_id);

	//$("#file-folder").show();
	$("#file-folder").dialog('open')
	document.superPage.NewObject.focus();

	// 
	$("#file-folder").keyup(function (eventage) {
		/* alert(eventage.which + " ... " + eventage.keyCode); */
		// fix toggle glitch!!!
		if (eventage.keyCode === 27) {
			//console.log(eventage);
			eventage.stopImmediatePropagation();
			//console.log(target);
			$(target).trigger('click');
			$(target).unbind();
			$(target).toggle(superMenuIn, superMenuOut);
			superMenuOut(); // just in case :/
		}
	});
};