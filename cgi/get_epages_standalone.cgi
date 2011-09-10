#!/usr/bin/env ruby
# get_epages_standalone.cgi

# ruby sqlite3 - it's all here - _all_ here
# http://sqlite-ruby.rubyforge.org/sqlite3/faq.html

print <<-PREAMBLE
Content-type: text/html

<script type='text/javascript' src='https://www.google.com/jsapi?key=ABQIAAAAUzJ_6UqPfuuygp9Xo0AGoxRYjYHH-N6Ytftz1YKT8IaSgMm3fBSIC090wMAgB4Mcecyj6FsiJdo98g' > </script>
<script src='https://ajax.googleapis.com/ajax/libs/jquery/1.5/jquery.min.js'> </script>
PREAMBLE

$STANDALONE = true
$GET_EPAGES = "cgi/get_epages_standalone.cgi"

require 'get_epages_shared'
