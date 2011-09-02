class File
  
  def self.here(string)
  	begin
  		raise "it up the flagpole to see who salutes"
  	rescue Exception => stiffy
  		snarf = stiffy.backtrace[1]
  		matched = /(.+?)[:]/.match(snarf) # +? non-greedy
  		context = matched[1]
  		first_letter = context[0]
  		case first_letter
  		when 40 # _(_ we do not handle (irb) and (eval) and whatever else yet 
  			return Dir.getwd + '/' + string
  		when 47 # _._ relative
  			return File.dirname(context) + '/' + string 
  		when 46 # _/_ absolute
  			return expand_path(File.dirname(context)) + '/' + string
  		else # huh?
  			raise NameError.new("odd name found in backtrace -- " + context)
  		end
  	end
  end

end

# Dir.getwd is not always the dir of the file being interpreted

# so the pattern has been 
# $:.unshift(File.dirname(__FILE__))
# which according to http://gilesbowkett.blogspot.com/2009/04/unshiftfiledirnamefile.html
# This shit is evil. People are undecided as to how evil, but evil it is.

# preferable is 
# require File.expand_path(File.dirname(__FILE__)) + "foo"

# but then you have a load of File.expand_path(File.dirname(__FILE__)) everywhere
# so it would be nice to have File.here , as in
# require File.here "foo"

require File.here "poetify/epoem"
require File.here "poetify/form_post"