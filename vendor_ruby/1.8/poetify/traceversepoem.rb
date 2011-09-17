
# to mix in think of it as -able

# to use as a namespace just mod::

module TraceversePoem # should inherit from Reverse and change what is necessary

	def self.poem_body params
		{
		:poem0 => params['poem0'],
		:poem1 => params['poem1'],
		:suggest_trace_text => params['suggest_trace_text'],
		:ignore_trace => params['ignore_trace']
		}
	end
	
	def self.simply(id, label)
		"http://web.durity.com:8080/cgi/test_work_on_traceverse.cgi?id=#{id}&name=#{Rack::Utils.escape(label)}"
	end
	
	def self.render
		:template_traceverse
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
	
	def poem0
		@input.poem0
	end
	
	def suggest_trace_text
		@input.suggest_trace_text
	end
	
	def trace_text
		@input.trace_text
	end
	
end
