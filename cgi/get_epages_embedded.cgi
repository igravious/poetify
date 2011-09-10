#!/usr/bin/env ruby
# get_epages_embedded.cgi

# UGLY, IMPERFECT -- BUT FUNCTIONAL

# this gets pulled into another page so it is not standalone

$GET_EPAGES = ENV['HTTP_REFERER'].split('/').last

# this is needed even with ajax pulling html into a page
# what other headers do i need?
print <<-PREAMBLE
Content-type: text/html

PREAMBLE

# p ENV

require 'get_epages_shared'
