#!/usr/bin/env ruby
# test_work_on_reverse.cgi

# UGLY (BUT NOT TOO UGLY!), IMPERFECT -- BUT FUNCTIONAL

begin

	require 'da_common'
	
	cgi = CGI.new
	params = cgi.params
	# p ENV
	# p params
	id = params["id"].first.to_i
	epage = EPage.find(id)
		
rescue Exception => bang

	info_tastic bang
	exit
	
end

print <<-ORIGINAL_PAGE
<meta content="text/html; charset=utf-8" http-equiv="Content-Type"/>
<script type="text/javascript" src="https://www.google.com/jsapi?key=ABQIAAAAUzJ_6UqPfuuygp9Xo0AGoxRYjYHH-N6Ytftz1YKT8IaSgMm3fBSIC090wMAgB4Mcecyj6FsiJdo98g"></script>
  
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.5/jquery.min.js"></script>

<link type="text/css" rel="stylesheet" media="screen" href="/css/poetify.css" />

<div id="center_it" style="width:800px;"> <!-- adjust as necessary -->
	<script>
	$(function() {
		// Handler for .ready() called.
		the_top = $("#center_it").offset().top;
 		the_left = (($(window).width() - 800)/2);
 		// alert(the_top + " --- " + the_left);
 		$("#center_it").offset({ top: the_top, left: the_left });
	});
	
	function stopEvent(e) {
    	if (!e) e = window.event;
    	if (e.stopPropagation) {
        	e.stopPropagation();
    	} else {
        	e.cancelBubble = true;
    	}
	}
	
	function cancelEvent(e) {
    	if (!e) e = window.event;
    	if (e.preventDefault) {
        	e.preventDefault();
    	} else {
        	e.returnValue = false;
    	}
	}

	var publish = function(button) {
        alert('This eventually will generate a publishing slip.'+String.fromCharCode(0x0A)+'The slip will contain authorship rights and legalese and so on.');
        stopEvent();
        return false;
    }
	
	var do_validation = function(obj) {		
		/*
			run the gauntlet
			http://www.qodo.co.uk/blog/javascript-trim-leading-and-trailing-spaces	
		*/
		
	try {
		var poem0 = document.formly.poem0.value;
		var where = poem0.indexOf('//')
		if (where != -1) {
			alert("Not going to try: Found 2 or more / together in left-hand poem at position " + where);
			stopEvent(null);
			return false;
		}
		var poem1 = document.formly.poem1.value;
		where = poem1.indexOf('//')
		if (where != -1) {
			alert("Not going to try: found 2 or more / together in right-hand poem at position " + where);
			stopEvent(null);
			return false;
		}
		
		// remove trailing whitespace
ORIGINAL_PAGE
		puts '		poem0 = poem0.replace(/(\s*$)/gi,"");'
		puts '		poem1 = poem1.replace(/(\s*$)/gi,"");'
print <<-ORIGINAL_PAGE
		
		var poem_array0 = poem0.split(''+String.fromCharCode(0x0A));
		var poem_array1 = poem1.split(''+String.fromCharCode(0x0A));
		
		if (poem_array0.length != poem_array1.length) {
			alert("Not going to try: found differing number of lines " + poem_array0.length + " versus " + poem_array1.length);
			stopEvent(null);
			return false;
		}
		
		/* each line must match :) */
		for (var j = 0; j < poem_array0.length; j += 1) {
			if (poem_array0[j].split('/').length != poem_array1[j].split('/').length) {
				alert("Not going to try: found differing number of / on line " + j);
				stopEvent(null);
				return false;
				}
  		}
  		document.formly.method="get";
		document.formly.action="http://web.durity.com:3301/woah";
		return true;
	} catch(err) {
  		txt="There was an error on this page. ";
  		txt+="Error description: " + err.description + String.fromCharCode(0x0A);
  		txt+="Click OK to continue.";
  		alert(txt);
  		stopEvent(null);
  		return false;
  	}
	};
	</script>
	
	<form name='formly' class='classy' action="zpoet/default" method="post">
	<!-- zpoet is a dumb name, come up with a decent name that does not start with p -->
	<fieldset> <legend class="classy">Re:Verse</legend>
	<br>
	The title of your ePoem: <input type="text" name="ePoem_title" id="ePoem_title" class="" /> (or leave blank if untitled)
	<br>
	<br>
	<table id="left_and_right" class="tabular" border="2" cellspacing="0" cellpadding="7"> 
	<tr>
	<th>::</th> 
	<th>::</th> 
	</tr>
	<tr>
	<td>
ORIGINAL_PAGE

puts "<textarea id='left' name='poem0' rows='24' cols='49'>"
if !epage[:body].nil? and !epage[:body][:poem0].nil? and !epage[:body][:poem0].empty?
	print epage[:body][:poem0]
end
puts "</textarea>"
puts "	</td>"
puts "	<td>"
puts "<textarea id='right' name='poem1' rows='24' cols='49'>"
if !epage[:body].nil? and !epage[:body][:poem1].nil? and !epage[:body][:poem1].empty?
	print epage[:body][:poem1]
end
puts "</textarea>"

print <<-ORIGINAL_PAGE
	</td>
	</tr>
	</table>
	<br>
	The name of your ePage is <b><span id='old_ePage_name_display'></span></b> or rename it to something new here <input type="text" name="new_ePage_name" id="ePage_name" class="" />
	<br>
	<input id="" class="" name="Save" type="submit" value="Save Me!"
			onclick='javascript:document.formly.action="http://web.durity.com:3301/save"'/>&nbsp;
	<input id="" class="" name="Try" type="submit" value="Try Me!"
			onclick='javascript:return do_validation(this);'/>&nbsp;
	<input id="" class="" name="Publish" type="submit" value="Publish Me!" onclick="javascript:publish(this);" />
	<!-- 	should be "put" "redirect" "get" pattern, put to temp rows in a publish table which are overwritten
		onclick='javascript:document.formly.method="put"; document.formly.action="http://web.durity.com:3301/publish"; '
	-->
	
	<input id="ePoem_type" class="" name="ePoem_type" type="hidden" value="2"/> <!-- Reverse -->
	<input id="old_ePage_name" class="" name="old_ePage_name" type="hidden" value=""/>
	<input id="ePage_id" class="" name="ePage_id" type="hidden" value=""/>
	
	<a style="float:right" href='/cgi/epoet_landing_page.cgi'>back to the landing page</a>
	</fieldset>
	</form>
	
</div>

<script>
$.extend({
  getUrlVars: function(){
    var vars = [], hash;
    var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
    for(var i = 0; i < hashes.length; i++)
    {
      hash = hashes[i].split('=');
      vars.push(hash[0]);
      vars[hash[0]] = hash[1];
    }
    return vars;
  },
  getUrlVar: function(name){
    return $.getUrlVars()[name];
  }
});

$(function() {
 // Handler for .ready() is called
 name = unescape($.getUrlVar('name'));
 id = $.getUrlVar('id')
 // show it
 $('#old_ePage_name_display').empty().append(name).css('color', 'green');
 // save it
 $('#old_ePage_name').val(name);
 // and save the id
 $('#ePage_id').val(id);
});
</script>

ORIGINAL_PAGE
