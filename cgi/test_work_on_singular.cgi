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
	# p id
	epage = EPage.find(id)
	# p CGI.escapeHTML(epage.inspect)
	# exit!
	
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

	</script>

	<form name='formly' class='classy' action="zpoet/publish" method="post"> <!-- zpoet is a dumb name, come up with a decent name that does not start with p -->
	<fieldset> <legend class="classy">Singular</legend>
	<br>
	The title of your ePoem: <input type="text" name="ePoem_title" id="ePoem_title" class="" /> (or leave blank if untitled)
	<br>
	<table id="left_and_right" class="tabular" border="2" cellspacing="0" cellpadding="7"> 
	<tr>
	<th>::</th>
	</tr>
	<tr>
	<td>
ORIGINAL_PAGE

puts "<textarea id='left' name='poem0' rows='32' cols='80'>"
if !epage[:body].nil? and !epage[:body][:poem0].empty?
	print epage[:body][:poem0]
end
puts "</textarea>"

print <<-ORIGINAL_PAGE
	</td>
	</tr>
	</table>
	<br>
	The name of your ePage is <span id='old_ePage_name_display'></span> or enter a new name here <input type="text" name="new_ePage_name" id="ePage_name" class="" />
	<br>
	<br>
	<input id="" class="" name="Save" type="submit" value="Save Me!"
			onclick='javascript:document.formly.action="http://web.durity.com:3301/save";'/>&nbsp;
	<input id="" class="" name="Try" type="submit" value="Try Me!"
			onclick='javascript:document.formly.method="get";document.formly.action="http://web.durity.com:3301/woah";'/>&nbsp;
	<input id="" class="" name="Publish" type="submit" value="Publish Me!" onclick="javascript:return publish(this);" />
        <!--    should be "put" "redirect" "get" pattern, put to temp rows in a publish table which are overwritten
                onclick='javascript:document.formly.method="put"; document.formly.action="http://web.durity.com:3301/publish"; '
        -->

	<input id="ePoem_type" class="" name="ePoem_type" type="hidden" value="1"/> <!-- Singular -->
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

rescue Exception => bang

	info_tastic bang
	exit
	
end
