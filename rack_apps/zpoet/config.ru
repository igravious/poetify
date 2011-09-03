
# you could put ruby files that both CGI and Rack Apps need
# in a place relative to the Web Server root or in a gema

# def required_reading env
#   $:.unshift( File.join(env['DOCUMENT_ROOT'],"vendor_ruby") )
#   $:.unshift( File.join(env['DOCUMENT_ROOT'],"vendor_ruby","1.8") )
#   require 'poetify'
# end

require 'rubygems'
require 'camping'

### Begin Camping application ###
Camping.goes :Poetify

# def create
#   $stderr.puts "am i here?"
# end

module Poetify

  def self.common_files root
    path = File.join(root,"vendor_ruby")
    $:.unshift(path) if !$:.include?(path)
    path = File.join(root,"vendor_ruby","1.8")
    $:.unshift(path) if !$:.include?(path)
    require 'poetify'
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
      self.common_files '/var/www/localhost/htdocs'
    else
      $stderr.puts "already loaded bud"
    end
  end
  
  def self.create
    self.required_reading
  end
  
  def self.new # just for class, not for Module?
  end

end

module Poetify::Models
  # class Post < Base; end
end

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
  
end

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
  	form.published "poem published" do
  		div.stylish "Poet ()"
  		div.stylish "Date ()"
  		div.stylish "Copyright ()"
  		div.stylish "Link to work ()"
  		div
  		div.stylish "<= undo, go back"
  	end
  end
  
  def hello
  	"Hello, World!"
  end
  
  def info
    # @posts.each do |post|
    h1 "$: path"
    $:.each do |path|
      # h1 post.title
      # div.stylish (post.body)
      div.stylish(path)
    end
    h1 "current working dir"
    div.stylish Dir.getwd
    h1 "ENV variables"
    env.each do |e_var|
      # h1 post.title
      # div.stylish (post.body)
      div.stylish("#{e_var}")
    end

  end
  
end

# this does nothing in Camping server/console, just needed for pure Rack Apps?
case ENV['RACK_ENV']
  when 'development'
    $stderr.puts "i'm in dev mode"
  when 'production'
    $stderr.puts "i'm in live mode"
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