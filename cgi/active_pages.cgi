#!/usr/bin/env ruby
# get_epages_embedded.cgi

# UGLY, IMPERFECT -- BUT FUNCTIONAL

begin

	def test_dynamic_load
		the_type = 2
		e_poem_module = EPoem.type(the_type)
		$stderr.puts e_poem_module.send('hello')
		$stderr.puts e_poem_module::hello
		$stderr.puts e_poem_module.hello
	end

	# COMMON ???
	
	# check for CGI mode?
	# ENV['GATEWAY_INTERFACE'] => "CGI/1.1"
  	puts "Content-type: text/html"
	puts
	$stderr.puts "pretty sure i'm in cgi mode"

	require 'yaml'
	# should be a symlink to the config file
	yml = YAML::load_file('.poetifyrc')

	require 'rubygems'
	
	require 'active_record'
	ActiveRecord::Base.establish_connection(yml['locations']['database_connection'])
	
	path_to_ruby = yml['locations']['vendor_ruby']
    $:.unshift(path_to_ruby) if !$:.include?(path_to_ruby)
    path_to_ruby = File.join(path_to_ruby,"1.8")
    $:.unshift(path_to_ruby) if !$:.include?(path_to_ruby)
	
	# has ActiveRecord mappings and autoloads and common stuff
	require 'poetify'
	
	# COMMON ???
	
	test_dynamic_load
	
rescue Exception => bang

	puts "<hr>Error running script: " + bang + "<br>"
	trace = bang.backtrace
	puts trace.join("<br>")

	puts "<hr>Library Path <br>"
	$:.each { |x| puts x + "<br>"}

	puts "<hr>YAML from .poetifyrc <br>"
	p yml
	puts '<br>'

	puts "<hr>Environment (ENV) <br>"
	p ENV
	puts '<br>'
end



