#!/usr/bin/ruby
# publish_it.cgi

begin
require 'cgi'

	# Create a cgi object, with HTML 4 generation methods.
	cgi = CGI.new('html4')

	cgi_params = cgi.params

	poem_types = {
		'1:verse' => 'SingularPoem',
		're:verse' => 'ReversePoem',
		'n:verse' => 'NVersePoem'
		}

	poem_type = cgi_params['poem_type']

	begin
		require poem_types[poem_type]
	rescue Exception => bang
		print "Error loading poem type #{poem_type} :: #{bang.to_str}"
	end

	# check the poem for structural correctness and publish it to a file with the given title

	# title of poem can be empty?
	title = c_p["title"]

	file = FILE.new(title)

	file_name = 

	require 'erb'

	template = ERB.new(File ...)
	html_str = template.result(binding)

	# Ask the cgi object to send some text out to the browser.
	cgi.out {
		cgi.html {
			cgi.body {
			c_p.each {|k,v| cgi.div k.to_str }
			}
		}
	}

rescue StandardError => bang
	print "Error running script: " + bang
end