#!/usr/bin/env ruby
# get_epages_standalone.cgi

print <<-ORIGINAL_PAGE
Content-type: text/html

<head lang="en">

<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  
<script type="text/javascript" src="https://www.google.com/jsapi?key=ABQIAAAAUzJ_6UqPfuuygp9Xo0AGoxRYjYHH-N6Ytftz1YKT8IaSgMm3fBSIC090wMAgB4Mcecyj6FsiJdo98g"></script>
  
<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.5/jquery.min.js"></script>

<link type="text/css" rel="stylesheet" media="screen" href="/css/poetify.css" />

</head>

<body>
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
			Hello intrepid explorer. This is version 0.1.5 of Poetify and it is for demonstration
			purposes only - to give you a flavour of the functionality.
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
			<div> Yada yada yada </div>
  		</fieldset>
  		</form>
	
	</div>
  
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
    $("#resize_me").css( "width", (740 - $("#epages_form").width()) );
    $("#resize_me").css( "height", ($("#epages_form").height() - 26) );
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
  	  $("#resize_me").css( "width", (740 - $("#epages_form").width()) );
	  $("#resize_me").css( "height", ($("#epages_form").height() - 26) );
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