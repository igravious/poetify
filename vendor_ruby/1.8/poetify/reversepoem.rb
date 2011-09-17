
# to mix in think of it as -able

# to use as a namespace just mod::

module ReversePoem

	def self.poem_body params
		{ :poem0 => params['poem0'], :poem1 => params['poem1'] }
	end
	
	def self.simply(id, label)
		"http://web.durity.com:8080/cgi/test_work_on_reverse.cgi?id=#{id}&name=#{Rack::Utils.escape(label)}"
	end
	
	def self.render
		:template_reverse
	end
	
	# functions that are included in the controllers
	
	def either verse
		v = verse # trailing whitespace is stripped
		v.gsub!(/\r\n/, "\n") # turn CR+LF into newline
		# not at the moment
		# v.gsub!(/\/\//, "\n") # turn // into newline
		#
		v.rstrip!
		v.lstrip!
		w = ''
		v.split("\n").each do |line|
			w += line # for clarity
			w += "\\" # backslash
			w += "n"  # + n for newline in the multiline javascript string
			w += "\\" # single backslash before actual newline in document
			w += "\n" # actual newline (which split rightly discards)
		end
		w
	end
	
	def verse
		either @input.poem0 # @input is from where the module is mixed in to :)
	end
	
	def reverse
		either @input.poem1 # yeah, ditto
	end
	
end