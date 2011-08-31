require 'rubygems'
require 'camping'

### Begin Camping application ###
Camping.goes :Poetify

require 'epoem'
require 'form_post'

module Poetify::Models
  # class Post < Base; end
end

module Poetify::Controllers
  
  class Index
    def get
      # @posts = Post.all
      render :index
    end
  end
  
  class Publish
    def post
      # first use a generic parameter unpacker
      # must be a hash with at least {ePoem_type => "", ePoem_title => "", ePage_name => "", poem[0 .. n-1] => "", ePoem_effect = ""}
      # @e_poem is available to the view
      @e_poem = Poetify::unpack_params @request.params      
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
  end
  
  def hello
  	"Hello, World!"
  end
  
  def info
    # @posts.each do |post|
    h1 "$: path"
    $:.each do |path|
      # h1 post.title
      # div.stylish { post.body }
      div.stylish { path }
    end
    h1 "current working dir"
    div.stylish Dir.getwd
  end
  
end

run Poetify