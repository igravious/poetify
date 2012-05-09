
# to mix in think of it as -able

# to use as a namespace just mod::

module ReversePoem
  
  # use snake_case
  require File.here 'commonpoem'
  include CommonPoem

	def self.poem_body params
		{ :poem0 => params['poem0'], :poem1 => params['poem1'] }
	end
	
	def self.simply(id, label)
		"http://web.durity.com:8080/cgi/test_work_on_reverse.cgi?id=#{id}&name=#{Rack::Utils.escape(label)}"
	end
	
	def self.render
		:play_with_reverse
	end
	
	#
	# used by #verse and #reverse
	#
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
	
	#
	# for the rhtml, (it is so much easier than cs really)
	#
	def verse
		either @input.poem0 # @input is from where the module is mixed in to :)
	end
	
	#
	# for the rhtml
	#
	def reverse
		either @input.poem1 # yeah, ditto
	end
	
end