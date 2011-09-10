
# you could put ruby files that both CGI and Rack Apps need
# in a place relative to the Web Server root (or somewhere else) or in a gem

require 'rubygems'
require 'camping'

### Begin Camping application ###
Camping.goes :Poetify

# def create
#   $stderr.puts "am i here?"
# end

module Poetify

	def self.common_files path_to_ruby
    	$:.unshift(path_to_ruby) if !$:.include?(path_to_ruby)
    	path_to_ruby = File.join(path_to_ruby,"1.8")
    	$:.unshift(path_to_ruby) if !$:.include?(path_to_ruby)
	end

	# use sys logger

	@loaded = false # um, should this be self. or @@ :(
	def self.required_reading
		$stderr.puts "or how about now?"
		if !@loaded
			$stderr.puts "loading for your convenience"
			# root = env['DOCUMENT_ROOT']
			# required_reading
			# $stderr.puts ENV['PWD']
      		require 'yaml'
			# should be a symlink to the config file
			yml = YAML::load_file('.poetifyrc')
			require 'rubygems'
			require 'active_record'
			ActiveRecord::Base.establish_connection(yml['locations']['database_connection'])
			
			path_to_ruby = yml['locations']['vendor_ruby']
			self.common_files path_to_ruby
			
			require 'poetify' # gives you common stuff and the base class but that's about it
    	else
    		$stderr.puts "already loaded bud"
    	end
    end
  
	def self.create
		self.required_reading
	end
  
	def self.new # just for class, not for Module?
	end

end # module Poetify

module Poetify::Models
  # class Post < Base; end
end # Poetify::Models

module Poetify::Controllers
  
  # /zpoet
  class Index
    def get
      # @posts = Post.all
      render :index
    end
  end
  
  # /zpoet/publish
  class Publish
    def post
      # first use a generic parameter unpacker
      # must be a hash with at least {ePoem_type => "", ePoem_title => "", ePage_name => "", poem[0 .. n-1] => "", ePoem_effect = ""}
      # @e_poem is available to the view
      # @e_poem = Poetify::unpack_params @request.params
      # @e_poem.electronic_binding
      
      render :publish
    end
  end
  
  class Info
    def get
      render :info
    end
  end
  
  class Hello
  	def get
  		render :hello
  	end
  end
  
  # :8080/zpoet/save
  # :3301/save
  class Save
  	def post
  		# do not forget redirect
  		p_type = @request.POST()['ePoem_type']
  		@e_poem_module = EPoem.type(p_type) # use it :)
  		body = @e_poem_module::body @request.POST()
  		# ePage_id => table::epage_id
		id = @request.POST()['ePage_id']
		epage = EPage.find(id)
		title = @request.POST()['ePoem_title']
		if @request.POST()['new_ePage_name'] != '' and @request.POST()['new_ePage_name'] != @request.POST()['old_ePage_name']
  			@label = @request.POST()['new_ePage_name']
  		else
  			@label = @request.POST()['old_ePage_name']
  		end
		epage.update_attributes(
  			# ePoem_title => table::title (can be nil)
  			:title => title,
  			# new_ePage_name, old_ePage_name => table::label (must not be nil)
  			:label => @label,
  			# poem0, poem1 => table::body
  			:body => body,
  			# ePoem_type => table::kind
  			:kind => p_type
		)
  		render :save
  	end
  end # class Save
  
  # (\d+)
  # class class Show < R '/show/(.*?)'
  # class class Show < R '/show/(\d+)'
  class Show
  	def get
  		render :show
  	end
  end
    
end # Poetify::Controllers

module Poetify::Views
  
  def layout
    html do
      head { title "« zPoet »" }
      body { self << yield }
    end
  end
  
  def index
    div.stylish "zPoet activated"
  end
  
  def publish
  	# publishing slip, wrap in a form
  	
  	form :action => R(SomeController), :method => 'post' do
  		label 'Choose one', :for => 'chooser'; br
    	select :name => 'chooser', :size => 1 do
        	option "First"
        	option "Second"
        	option "Third"
    	end; br
    	div {[input(:type => 'radio', :name => 'radios',
          :value => 'one'), "One"].join(" ")}
    	div {[input(:type => 'radio', :name => 'radios',
          :value => 'two'), "Two"].join(" ")}
    	input :type => 'submit', :value => 'submit'
    end

  	# div.stylish "Poet ()"
  	# div.stylish "Date ()"
  	# div.stylish "Copyright ()"
  	# div.stylish "Link to work ()"
  	# div
  	# div.stylish "<= undo, go back"

  end
  
  def hello
  	"Hello, World!"
  end
  
  def info
    # @posts.each do |post|
      # h1 post.title
      # div.stylish (post.body)
    # end
    h1 "$: path"
    $:.each do |path|
      div.stylish(path)
    end
    h1 "current working dir"
    div.stylish Dir.getwd
    h1 "ENV variables (@env)"
    @env.each do |e_var|
      div.stylish("#{e_var}")
    end
  end
  
  def show
  	h1 "@env ... goodly"
  	@env.each do |e_var|
      div.stylish("#{e_var}")
    end
  end
  
  def save
  	# this is the view for save,
  	# don't do stuff in the view except redirecting to work_on ...
  	# h1 "@request.form_data"
	  	# div @request.form_data?
  	# h1 "@env.class"
  	# div @env.class
  	h1 "@env ... badly"
  	@env.each do |e_var|
      div.stylish("#{e_var}")
    end
    h1 "@request.POST()"
    @request.POST().each do |r_var|
      div.stylish("#{r_var}")
    end
    
    h1 'ePoem_title'
    div @request.POST()['ePoem_title']
    h1 'new_ePage_name'
    div @request.POST()['new_ePage_name']
    h1 'poem0'
    div @request.POST()['poem0']
    h1 'poem1'
    div @request.POST()['poem1']
    h1 'old_ePage_name'
    div @request.POST()['old_ePage_name']
    h1 'ePoem_type'
    div @request.POST()['ePoem_type']
    h1 'ePage_id'
    div @request.POST()['ePage_id']
    
    # change 
    id = request.POST()['ePage_id']
    # redirect (Show, :id => 1)
    # redirect "/show/id=#{id}"
    # http://web.durity.com:3301/show?id=1
    # http://web.durity.com:8080/cgi/test_work_on_reverse.cgi?id=1&name=rererere
    
    p Rack::Utils.escape(@e_poem_module.inspect)
    #exit!
    redirect @e_poem_module::simply(id, @label)
  end
  
end # Poetify::Views

# this does nothing in Camping server/console, just needed for pure Rack Apps?
case ENV['RACK_ENV']
  when 'development'
    $stderr.puts "i'm in rack dev mode"
  when 'production'
    $stderr.puts "i'm in rack live mode"
    run Poetify
  else
    raise 'unknown rack environment'
end

if __FILE__ == $0
  # this library may be run as a standalone script
  # as in -> ruby rack_apps/zpoet/config.ru
  # dunno why you'd want to do that but anyway
  # yay
  $stderr.puts "Hi there"
end
