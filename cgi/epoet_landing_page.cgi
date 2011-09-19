#!/usr/bin/env ruby
# get_epages_standalone.cgi

# version 0.1a dirty raine edition (dirty as in the code is a mess!)
# next version is going to be cleaned up, refactored, tracified

print <<-ORIGINAL_PAGE
Content-type: text/html

<head lang="en">

<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  
<script type="text/javascript" src="https://www.google.com/jsapi?key=ABQIAAAAUzJ_6UqPfuuygp9Xo0AGoxRYjYHH-N6Ytftz1YKT8IaSgMm3fBSIC090wMAgB4Mcecyj6FsiJdo98g"></script>
  
<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.5/jquery.min.js"></script>

<link type="text/css" rel="stylesheet" media="screen" href="/css/poetify.css" />

</head>

<body>
	<div>
	<!-- a href="http://web.durity.com:8080/cgi/epoet_landing_page.cgi" style="position: relative; font-size:400%; font-family:'times new roman',times,georgia,serif; padding:0.5em 0.2em; float:left; margin-left:0; margin-right:0; margin-top:0; margin-bottom; z-index:5">¶</a -->
	</div>
	<div id="center_it" style="width:800px;"> <!-- adjust as necessary -->
	<script>
	$(function() {
		// Handler for .ready() called.
		the_top = $("#center_it").offset().top;
 		the_left = (($(window).width() - 800)/2);
 		// alert(the_top + " --- " + the_left);
 		$("#center_it").offset({ top: the_top, left: the_left });
	});
	</script>
  
		<form id="resize_me_form" class="classy" style="float:left; ">
		<fieldset> <legend class="classy">Welcome</legend>
			<div id="resize_me">
			Welcome o seeker of rare pleasures. This is version 0.1.5 work-in-progress of
			Poetify and it is for demonstration purposes only - to give you a flavour of
			the functionality. This has been checked over in Chrome and Firefox - Internet
			Explorer probably does not work yet, awfully sorry about that.
			</div>
		</fieldset>
		</form>
	
		<form id="epages_form" class="classy" style="float:right;">
		<fieldset> <legend class="classy">ePages</legend>
			<div id="epages"></div>
		</fieldset>
		</form>
  
  		<form class="classy" style="clear:both">
  		<fieldset> <legend class="classy">Description</legend>
			<div id="description"></div>
  		</fieldset>
  		</form>
		
  		<form class="classy" style="clear:both">
  		<fieldset> <legend class="classy">Source, Copyright & Warranty</legend>
			<div>
                            <a href="https://github.com/igravious/poetify">Source Code at Github</a>
                            <br>
                            <i>Copyrighted 2011 by Anthony Durity using materials provided by Jyväskylä University under the <a href="http://www.gnu.org/licenses/gpl-3.0.html">GPL version 3</a></i>
                            <br>
                            In contrast to most software, this software actually does come with a limited warranty in that we hope that it is fit for its intended purpose and we pledge to try and fix any defects you may find (such defects exist in all software no matter how hard we try to eliminate them) and we pledge to provide a channel of communication for enabling this and other type of feedback. In return for these pledges, though, it is only fair that we are not held liable for any data or hair loss or what-have-you.
                        </div>
  		</fieldset>
  		</form>
	
	</span>
  
<script>
  $("#description").load("/cgi/red_or_dead.cgi?render=/var/www/localhost/htdocs/README.markdown", function(response, status, jqxhr) {
    if (status == "error") {
      var msg = "Sorry, but I couldn't load the README";
      /* $("#description").html(msg + jqxhr.status + " " + jqxhr.statusText); */
      $("#description").html(msg);
    }
  });
  
ORIGINAL_PAGE

require 'cgi'
cgi = CGI.new	

if cgi.request_method.downcase == 'post'
  params = cgi.params
  page = '/cgi/get_epages_embedded.cgi'
  data = '{'
  params.each_with_index {|pair,i| data += "#{ i==0 ? ' ' : ',' }'#{pair[0]}': '#{pair[1].first}'"}
  data += ' }'
  puts "  var jqxhr = $.post('#{page}', #{data}, function(response_data) {"
  print <<-ORIGINAL_PAGE
    /* alert('post?') */
    // Assign handlers immediately after making the request,
    // and remember the jqxhr object for this request
    $("#epages").html(response_data);
    $("#resize_me").css( "width", (750 - $("#epages_form").width()) );
    $("#resize_me").css( "height", ($("#epages_form").height() - 40) );
    window.location = '/cgi/epoet_landing_page.cgi'
  })
  .success(function() { /* alert("second success"); */ })
  .error(function() {
    var msg = "Sorry, but I couldn't load the ePages";
    $("#epages").html(msg + jqxhr.status + " " + jqxhr.statusText);
    /* $("#epages").html(msg); */
  })
  .complete(function() { /* alert("complete"); */ });
  // perform other work here ...
  // Set another completion function for the request above
  jqxhr.complete(function(){ /* alert("second complete"); */ });
ORIGINAL_PAGE
else
  print <<-ORIGINAL_PAGE
  /* alert('get?') */
  var epages_fn = function(response, status, jqxhr) {
    /* alert('back from ajax'); */
    if (status == "error") {
      var msg = "Sorry, but I couldn't load the ePages";
      $("#epages").html(msg + jqxhr.status + " " + jqxhr.statusText);
      /* $("#epages").html(msg); */
    } else {
  	  /* alert('yippee'); */
  	  $("#resize_me").css( "width", (750 - $("#epages_form").width()) );
	  $("#resize_me").css( "height", ($("#epages_form").height() - 40) );
    }
  }
  $("#epages").load("/cgi/get_epages_embedded.cgi", epages_fn);
ORIGINAL_PAGE
end

puts "</script>"

#puts "<hr>"
#p ENV

#puts "<hr>"
#p params
