
module Poetify

	# http://stackoverflow.com/questions/1235593/ruby-symbol-to-class
	# http://www.randomhacks.net/articles/2007/01/20/13-ways-of-looking-at-a-ruby-symbol
	# http://stackoverflow.com/questions/800122/best-way-to-convert-strings-to-symbols-in-hash
	# http://apidock.com/rails/Hash/symbolize_keys

	# POEM_TYPES maps user visible poem type to Ruby class name, both are symbols
	POEM_TYPES = {
		:'1:verse' => :SingularPoem,
		:'2:verse' => :TwoVersePoem,
		:'n:verse' => :NVersePoem,
		:'woven:verse' => :WovenVersePoem
		}
	
	# POEM_TYPES = { :'1:verse' => :SingularPoem, :'2:verse' => :TwoVersePoem, :'n:verse' => :NVersePoem, :'woven:verse' => :WovenVersePoem }
	
	def unpack_params(params)
		begin
			# get the poem type from the parameter list
			poem_type = params['ePoem_type']
			
			require POEM_TYPES[poem_type]
 
		rescue Exception => bang
			$stderr.write "Error loading poem type #{poem_type} :: I went #{bang.to_str}"
		end
	end
  
end
