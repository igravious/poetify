
# to mix in think of it as -able

# to use as a namespace just mod::

module ReversePoem

	# what is a module function not defined as self. ?
	def self.hello
		"hello there?"
	end
	
	def self.body params
		{ :poem0 => params['poem0'], :poem1 => params['poem1'] }
	end
	
	def self.simply(id, label)
		"http://web.durity.com:8080/cgi/test_work_on_reverse.cgi?id=#{id}&name=#{Rack::Utils.escape(label)}"
	end
end