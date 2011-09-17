
# to mix in think of it as -able

# to use as a namespace just mod::

require File.expand_path(File.join(*%w[ commonpoem ]), File.dirname(__FILE__))

module SingularPoem

	include CommonPoem
	
	def self.poem_body params
		{ :poem0 => params['poem0'] }
	end
	
	def self.simply(id, label)
		"http://web.durity.com:8080/cgi/test_work_on_singular.cgi?id=#{id}&name=#{Rack::Utils.escape(label)}"
	end
	
	def poem_title
		@input.ePoem_title
	end
	
	def poem_body
		v = @input.poem0 # trailing whitespace is stripped
		v.gsub!(/\r\n/, "\n") # turn CR+LF into newline
		v.rstrip!
		v.lstrip!
		w = ''
		v.split("\n").each do |line|
			w += line # for clarity
			w += "<br>"
		end
		w
	end

	def self.render
		:template_singular
	end
	
end