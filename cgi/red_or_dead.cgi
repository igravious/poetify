#!/usr/bin/env ruby
# red_or_dead.cgi

begin

	require 'cgi'
	# don't forget ruby gems
	require 'rubygems'
	require 'redcarpet'
	cgi = CGI.new
	params = cgi.params
	the_file = params['render'].to_s
	# Redcarpet.autolink
	
	puts "Content-type: text/html"
	puts
	# p cgi
	# p params
	# p the_file
	# p Dir.getwd
	# string = File.read(the_file)
	# p string
	# exit
	puts Redcarpet.new(File.read(the_file)).to_html

rescue Exception => bang

	puts "Content-type: text/html"
	puts
	puts "Error running script: " + bang + "<br>"
	trace = bang.backtrace
	puts trace.join("<br>")
	# $:.each { |x| puts x + "<br>"}
end
