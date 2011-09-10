
# to mix in think of it as -able

# to use as a namespace just mod::

module SingularPoem

	# what is a module function not defined as self. ?
	def self.hello
		$stderr.puts "ooga 1"
		"hello there?"
	end
	
	def self.body params
		$stderr.puts "booga 1"
		{ :poem0 => params['poem0'] }
	end
	
	def self.simply(id, label)
		$stderr.puts "pow 1"
		"http://web.durity.com:8080/cgi/test_work_on_singular.cgi?id=#{id}&name=#{Rack::Utils.escape(label)}"
	end
end