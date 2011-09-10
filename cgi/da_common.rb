
def info_tastic bang
	puts "<hr>Error in common code: " + bang + "<br>"
	trace = bang.backtrace
	puts trace.join("<br>")

	puts "<hr>Library Path <br>"
	$:.each { |x| puts x + "<br>"}

	# puts "<hr>YAML from .poetifyrc <br>"
	# p CGI.escapeHTML(yml)
	# puts '<br>'

	puts "<hr>Environment (ENV) <br>"
	p CGI.escapeHTML(ENV.inspect)
	puts '<br>'
end

begin

  # check for CGI mode?
	# ENV['GATEWAY_INTERFACE'] => "CGI/1.1"
  	puts "Content-type: text/html"
	puts
	$stderr.puts "pretty sure i'm in cgi mode in " + __FILE__

	require 'yaml'
	# should be a symlink to the config file
	yml = YAML::load_file('.poetifyrc')
	$stderr.puts yml

	require 'rubygems'
	
	require 'active_record'
	ActiveRecord::Base.establish_connection(yml['locations']['database_connection'])
	
	path_to_ruby = yml['locations']['vendor_ruby']
    $:.unshift(path_to_ruby) if !$:.include?(path_to_ruby)
    path_to_ruby = File.join(path_to_ruby,"1.8")
    $:.unshift(path_to_ruby) if !$:.include?(path_to_ruby)
	
	# has ActiveRecord mappings and autoloads and common stuff
	require 'poetify'

	require 'cgi'
	
rescue Exception => bang

	info_tastic bang	
	exit!
	
end