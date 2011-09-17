
# one could put ruby files that both CGI and Rack Apps need
# in a place relative to the Web Server root (or somewhere else) or in a gem
# if one was so inclined

require 'rubygems'

# use bundler

gem 'camping' , '>= 2.1'
gem 'tilt', '>= 1.3'

%w(tilt camping).each {|r| require r}

### Begin Camping application ###
Camping.goes :Poetify

# def create
#   $stderr.puts "am i here?"
# end

# == About config.ru a.k.a Poetify Camping Stylee
#
# yada yada yada
module Poetify

	@@yummy = ''
    def self.gimme_yml
    	$stderr.puts "as little as possible loading for your convenience"
		# root = env['DOCUMENT_ROOT']
		# required_reading
		# $stderr.puts ENV['PWD']
      	require 'yaml'
		# should be a symlink to the config file
		if @@yummy.empty?
			$stderr.puts "i'm empty"
			@@yummy = YAML::load_file('.poetifyrc')
		else
			$stderr.puts "i'm full"
		end
		@@yummy
    end
  
	# should i put them in the Camping Rack app? where in it?
	# or symlink to where the templates live in the ruby in vendor_ruby?
	# or somewhere else entirely
	def self.this_is_where_the_templates_are_found
		d = File.join(self.gimme_yml['locations']['vendor_ruby'],"1.8","poetify","templates")
		$stderr.puts "this is my view: #{d}"
		d
	end

	$stderr.puts "fuck a ducky"
	set :views, self.this_is_where_the_templates_are_found

	def self.add_ruby_and_co_to_library_load_path path_to_ruby #:nodoc:
    	$:.unshift(path_to_ruby) if !$:.include?(path_to_ruby)
    	path_to_ruby = File.join(path_to_ruby,"1.8")
    	$:.unshift(path_to_ruby) if !$:.include?(path_to_ruby)
	end
	
	# use sys logger

	@loaded = false # um, should this be self. or @@ :(
	
	#i do not understand this in relation to self.create in Camping
	#@@path_to_ruby = ''
	
	def self.required_reading
		$stderr.puts "in required_reading"
		if !@loaded
			@loaded = true
			$stderr.puts "loading stuff"
			yml = self.gimme_yml
			path_to_ruby = yml['locations']['vendor_ruby']
			require 'rubygems'
			# db URLs à la here: http://devcenter.heroku.com/articles/rack
			# http://en.wiktionary.org/wiki/%C3%A0_la http://en.wiktionary.org/wiki/à_la
			require 'active_record'
			ActiveRecord::Base.establish_connection(yml['locations']['database_connection'])
			
			self.add_ruby_and_co_to_library_load_path path_to_ruby
			require 'poetify' # gives you common stuff and the base class but that's about it
    	else
    		$stderr.puts "already loaded buddy"
    	end
    end
    
    # Poetify.create is only called once per Camping invocation (lifetime of App)
    # so only put per-app invocation stuff here like db connections and config File reading
	def self.create
		$stderr.puts "in create"
		self.required_reading
	end
  
end # module Poetify

module Poetify::Models
  # class Post < Base; end
end # Poetify::Models

module Poetify::Controllers

  module Kommon
  
    def document_root # or whatever ...
      '/var/www/localhost/htdocs/'
    end
    
    def http_host # or whatever ...
      'http://web.durity.com:8080/'
    end
    
  end

  class StaticImage < R '/images/(.*)'
    def get(static_name)
      the_dir = ''
      @headers['Content-Type'] = "image/png"
      @headers['X-Sendfile'] = "#{the_dir}/images/#{static_name}"
    end
  end
  
  class FavIcon < R '/favicon.ico'
    include Kommon
    def get
      @headers['Content-Type'] = "image/x-icon"
      @headers['X-Sendfile'] = document_root + '/favicon.ico'
    end
  end
  
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
		@input.each do |x|
			$stderr.puts x.inspect
		end
  		poem_type = @request.POST()['ePoem_type']
  		@e_poem_module = EPoem.type(poem_type) # use it :)
  		poem_body = @e_poem_module::poem_body @request.POST()
  		# ePage_id => table::epage_id
		id = @request.POST()['ePage_id']
		epage = EPage.find(id)
		poem_title = @request.POST()['ePoem_title']
		if @request.POST()['new_ePage_name'] != '' and @request.POST()['new_ePage_name'] != @request.POST()['old_ePage_name']
  			@poem_label = @request.POST()['new_ePage_name']
  		else
  			@poem_label = @request.POST()['old_ePage_name']
  		end
		epage.update_attributes(
  			# ePoem_title => table::title (can be nil)
  			:title => poem_title,
  			# new_ePage_name, old_ePage_name => table::label (must not be nil)
  			:label => @poem_label,
  			# poem0, poem1 => table::body
  			:body => poem_body,
  			# ePoem_type => table::kind
  			:kind => poem_type
		)
  		render :save
  	end
  end # class Save
  
  # :8080/zpoet/woah
  # :3301/woah
  class Woah
  
  	include Kommon
  	
  	def title # put in included module that is drawn into specialized poems? 
		@input.title
	end

  	def get
  		@input.each do |x|
			$stderr.puts x.inspect
		end
  		poem_type = @input.ePoem_type
  		@e_poem_module = EPoem.type(poem_type) # use it :)
  		
  		#@verse = @input.poem0
  		#@reverse = @input.poem1
  		
  		# module will know how
  		#self.extend @e_poem_module
  		#$stderr.puts "1 -> "
  		Woah.send(:include, @e_poem_module)
  		#$stderr.puts self.methods.join("\n")
  		render @e_poem_module::render
  		#$stderr.puts "2 -> "
  	end
  end
  
  # class Show < R '/show/(.*?)'
  # class Show < R '/show/(\d+)'
  class Show
  	def get
  		render :show
  	end
  end
    
end # Poetify::Controllers

module Poetify::Views
  
#  def layout # how to exclude templates?
#    html do
#      head { title "« zPoet »" }
#      body { self << yield }
#    end
#  end
  
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
  
#  def woah
  	# require 'erb'
	# template = ERB.new(IO.read(File.join(Poetify::gimme_yml['locations']['vendor_ruby'],"1.8","poetify","templates","template_reverse.rhtml")))
	# verse = @verse
	# reverse = @reverse
	# html_str = template.result(binding)
	# html_str
	#"fuck?"
#  end
  
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
    
    # p Rack::Utils.escape(@e_poem_module.inspect)
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
