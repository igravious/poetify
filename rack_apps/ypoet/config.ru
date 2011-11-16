
#$DEBUG=true

%w{rubygems pry camping camping/session tarpaulin rack-flash gettext}.each{|g| require g}

#now we have the logger, set the program name
$L.progname = "SanSan"
$L.debug "Current working directory is: "+Dir.getwd
Neo::Cs.bindtextdomain "poetify", Dir.getwd+"/locale"
GetText::bindtextdomain('poetify', :path => Dir.getwd+'/locale')
GetText::textdomain('poetify')

Camping.goes :YPoet

# you #include stuff to mix it in
# you #use stuff to chain a middleware
module YPoet
  include CampingFlash # must go first
  include CampingHooks
  include HttpAcceptLanguage
  
  # Camping invocation of rack-flash
  use( Rack::Flash, :flash_app_class => self, :accessorize => [:notice, :alert] )
  use Rack::MethodOverride # for PUT and DELETE
  set :secret, "slartibartfast"
  include Tarpaulin
  include Camping::Session
end

module YPoet::Helpers
  include Tarpaulin::Helpers
  
  def unredirect_with(url)
    redirect url
    throw :halt, self
  end
  
  def red_or_dead the_file # make this a rake task
    require 'redcarpet'
    Redcarpet.new(File.read(the_file)).to_html
  end
  
  def link_controller
    TheApp::Controllers::Dyn
  end
  
  def lingua
    {:locale => @locale.first.gsub('-','_')+'.UTF-8'}
  end
end
  
module YPoet::Controllers 
  class DoYouCookie
    def get
      if @cookies["already_checked"] == "true"
        unredirect_with @input.referer
      else
        raise "You need cookies enabled to use Poetify for now, sorry"
      end
    end
  end
end 

module YPoet
  def check_for_cookies!
    # oh the magic incantation
    if @env['PATH_INFO'] == R(YPoet::Controllers::DoYouCookie)
      $L.debug "who will test the testers?".red
      @body = '<title>knock knock</title>'
      response = Rack::Response.new @body, @status, @headers
      response.finish
    else
      @status = 302
      @headers.merge!( 'Location'=>URL(YPoet::Controllers::DoYouCookie).to_s+"?referer=#{@env['PATH_INFO']}" )
      @body = ''
      response = Rack::Response.new @body, @status, @headers
      #response.set_cookie("already_checked", {:value => "true", :path => "/", :expires => Time.now+10*60})
      response.set_cookie("already_checked", true)
      response.finish
    end
    @status = response.status.to_i
    @headers = response.headers
    @body = response.body
    throw :halt, self
  end
  
  def force_option_id
    redirect R(YPoet::Controllers::DoYouCookie)+"?referer=#{@env['PATH_INFO']}"
    throw :halt, self
  end
  
  # how about cookieless?
  # All pages and folders lets you change desc. of pad
  # this uses the session, so it's wrong (it'll expire)
  # need to cache
  def perm_pad
    if !@cookies.remember_me
      check_for_cookies! unless @cookies.already_checked
      require 'digest'
      h = Digest::SHA2.hexdigest('slartibartfast'+Time.now.to_s+@env['REMOTE_ADDR'])
      p = PoemPad.where(:unique_id => h).first
      if p
        raise "using pad with existing option id: "+h
      else
        $L.debug "creating pad with option id: "+h
        p = PoemPad.create(:unique_id => h)
        @cookies.remember_me = {:value => h, :path => "/", :expires => Time.now+365*24*60*60, :httponly => true}
      end
    else
      p = PoemPad.where(:unique_id => @cookies.remember_me).first
      if p
        $L.debug "using pad with existing session id: "+@cookies.remember_me
      else
        $L.warn "creating pad with session id (why was this not already done?): "+@cookies.remember_me
        p = PoemPad.create(:unique_id => @cookies.remember_me)
      end      
    end
    raise "I don't remember you man. Clean your damn cookies!" if !p
    @p = p
  end
  
  # need :all_bar Foo
  hook :before_service => :all do
    #$L.debug self.class.to_s.light_red
    #$L.debug @env['PATH_INFO'].to_s.light_red
    #$L.debug @env['HTTP_COOKIE'].red

    next if self.class == YPoet::Controllers::I
    @locale = user_preferred_languages
    @language = compatible_language_from(['it', 'en'])    
    # skip the catch all class
    next if self.class == YPoet::Controllers::Dyn # use next instead of return cuz of Thread/Proc error
    #pad_helper_session
    perm_pad
  end
  
  hook :after_service => :all do
  end
  
  @@yummy = ''
  def self.gimme_yml
    require 'yaml'
    # should be a symlink to the config file
    if @@yummy.empty?
        @@yummy = YAML::load_file('.poetifyrc')
    else
    end
    @@yummy
  end

  # should i put them in the Camping Rack app? where in it?
  # or symlink to where the templates live in the ruby in vendor_ruby?
  # or somewhere else entirely
  def self.this_is_where_the_templates_are_found
    #d = File.join(self.gimme_yml['locations']['vendor_ruby'],"1.8","poetify","templates")
    d = File.dirname(__FILE__) + '/templates'
    d
  end

  set :views, self.this_is_where_the_templates_are_found

  def self.add_ruby_and_co_2_load_path path_2_ruby #:nodoc:
    $:.unshift(path_2_ruby) if !$:.include?(path_2_ruby)
    path_2_ruby = File.join(path_2_ruby,"1.8")
    $:.unshift(path_2_ruby) if !$:.include?(path_2_ruby)
  end
  
  @@loaded = false # um, should this be self. or @@ :(

  #i do not understand this in relation to self.create in Camping
  #@@path_to_ruby = ''

  def self.required_reading
    if !@@loaded
      @@loaded = true
      yml = self.gimme_yml
      path_to_ruby = yml['locations']['vendor_ruby']
      self.add_ruby_and_co_2_load_path path_to_ruby
      require 'rubygems'
      require 'active_record'
      # db URLs à la here: http://devcenter.heroku.com/articles/rack
      # http://en.wiktionary.org/wiki/%C3%A0_la http://en.wiktionary.org/wiki/à_la
      ActiveRecord::Base.establish_connection(yml['locations']['database_connection'])
      ActiveRecord::Base.connection.execute('PRAGMA foreign_keys = ON')
      require 'poetify_redux' # gives you common stuff and the base class but that's about it
      EPoem.init_db yml
    else
    end
  end

end

require File.here "models"

module YPoet::Controllers
  
  #
  # /another
  #
  class Xray
    def get
      # "fudge"
      render(:inner_two, {:layout => false}) { Neo::Hdf.new }
    end
  end

  class Tango_delta
    def get
      # "behold majestic world"
      render(:inner_one, {:layout => false}) { Neo::Hdf.new }
    end
  end
  
  class Another
    def initialize(e, m)
      super e, m
    end
        
    def get
      render(:outer) { Neo::Hdf.new }
      # render(:outer, {:locals => [@env, @method]}) { Neo::Hdf.new }
      # "...\n"
      # render :foo
    end
  end
  
  #
  #
  #
  class Index # RegexpError: regular expression too big:
    def get
      "try /landing or /another\n"
    end
  end
  
  #
  # this is what is called when ClearSilver `include`s another file
  #
  def self.dispatch(route, unpack)
    e,m = unpack
    
    c,m,*p = D(route, m, e)
    o = c.new(e, m)
    if p.empty?
      o.send(m.to_sym)
    else
      o.send(m.to_sym, *p) # must be splatted?
    end
  end
  
  #
  # these are to test @state, please ignore them
  #
  class Plus
    def post
      raise "gimme something to work with here buddy" if @input.plus_text.length == 0
      @state[@input.plus_text] = "urk!"
      pp @state
      redirect YPoet::Controllers::Landing
    end
  end
  
  class Minus
    def post
      raise "gimme something to work with here buddy" if @input.minus_text.length == 0
      @state.delete(@input.minus_text)
      pp @state
      redirect YPoet::Controllers::Landing
    end
  end
  
  #
  # flash.now[] before a render
  # flash[] before a redirect
  #
  class Borked
    def post
      raise "raised a generic error"
    rescue => e
      # should pass in e and have the flash print dev e.message or friendly user message
      env['x-rack.flash'].alert = e.message
      flash[:notice] = "This really is a pain in the neck" # nice, flash works ...
      # should pass in e and have the logger decide whether backtrace is printed or not
      $L.error { e.message }
    ensure
      redirect YPoet::Controllers::Landing
    end
  end
  
  class Inspect
    def post
      binding.pry
      redirect YPoet::Controllers::Landing
    end
  end
  
  class EmptyTrash
    def put
      EPoem.empty_trash(@p)
      redirect YPoet::Controllers::Landing
    end
  end
  
  class EpageN
    def get(id) # show and edit a poem
      epage = EPage.find(id)
      if @input.version
        epage.revert_to @input.version.to_i
      end
      poem = Neo::Hdf.new
      poem.set_value "id", id
      poem.set_value "label", epage[:label]
      poem.set_value "title", epage[:title]
      poem.set_value "version", epage.version
      @title = 'your lovely little poem'
      poem0 = ""
      if !epage[:body].nil? and !epage[:body][:poem0].nil? and !epage[:body][:poem0].empty?
        poem0 = epage[:body][:poem0]
      end
      poem.set_value "poem0", poem0
      case epage[:kind]
        when 1
          v = :singular
        when 2
          v = :reverse
        when 3
          v = :multiverse
        when 4
          v = :traceverse
      end
      if epage[:kind] == 2 or epage[:kind] == 4
        poem1 = ""
        if !epage[:body].nil? and !epage[:body][:poem1].nil? and !epage[:body][:poem1].empty?
          poem1 = epage[:body][:poem1]
        end
        poem.set_value "poem1", poem1
      end
      render(v) { poem }
    rescue
      $L.error $!.message
      flash[:alert] = $!.message
      redirect YPoet::Controllers::Landing 
    end
    
    def put(id) # save a poem
      poem_type = @request.POST()['ePoem_type']
      @e_poem_module = EPoem.type(poem_type) # use it :)
      poem_body = @e_poem_module::poem_body @request.POST()
      # ePage_id => table::epage_id
      # id = @request.POST()['ePage_id']
      @id = id
      epage = EPage.find(@id)
      poem_title = @request.POST()['ePoem_title']
      n = @request.POST()['new_ePage_name']
      o = @request.POST()['old_ePage_name']
      if n != '' and n != o
        @poem_label = n
      else
        @poem_label = o
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
      # set correct href, action, src using CS
      redirect R(self.class, @id)
      # redirect R(YPoet::Controllers::EpageN, @id)
    end
    
    # trash should
    # A. appear localized
    # B. at the bottom
    # can't create or move or delete stuff from it or to it
    # pages in it are either unviewable or viewable readonly
    
    def delete(id)
      EPoem.trash_epage(@p, id)
      redirect YPoet::Controllers::Landing
    end
  end

  class EpagePromoteN
    def get(version) # should be POST
      epage = EPage.find(@input.id)
      epage.revert_to!(version.to_i)
      redirect R(YPoet::Controllers::EpageN, @input.id)
    end
  end
  class EpageRevertToN
    def get(version) # should be PUT
      epage = EPage.find(@input.id)
      #epage.revert_to(version.to_i)
      redirect R(YPoet::Controllers::EpageN, @input.id)+"?version=#{version}"
    end
  end
  class EpageEraseToN
    def get(version) # should be DELETE
      epage = EPage.find(@input.id)
      epage.reset_to!(version.to_i)
      redirect R(YPoet::Controllers::EpageN, @input.id)
    end
  end
    
  class EpageHistoryN
    
    def strip_tz_offest str
      str = str.to_s
      str.split[0..3].join(' ') + ' ' + str.split[5]
    end
    
    def link_to(id, *a)
      "<a href='#{R(*a)}?id=#{id}'>#{R(*a)}</a>" 
    end
    
    def get(id)
      epage = EPage.find(id)
      if @input.version
        epage.revert_to @input.version.to_i
      end
      poem = Neo::Hdf.new
      poem.set_value "id", id
      mods = epage.versions.length # does not include first version
      
      promote = YPoet::Controllers::EpagePromoteN
      revert = YPoet::Controllers::EpageRevertToN
      erase = YPoet::Controllers::EpageEraseToN

      mods.downto(1) do |n|
        poem.set_value "versions.#{n+1}.number", (n+1)
        poem.set_value "versions.#{n+1}.created_at", (strip_tz_offest epage.versions[n-1].created_at)
        poem.set_value "versions.#{n+1}.mod", (mods==n ? "latest version" : "modification")
        poem.set_value "versions.#{n+1}.promote", link_to(id, promote, n+1)
        poem.set_value "versions.#{n+1}.j_promote", ''
        poem.set_value "versions.#{n+1}.revert_to", (epage.version==n+1 ? '_' : link_to(id, revert, n+1))
        poem.set_value "versions.#{n+1}.j_revert_to", ''
        poem.set_value "versions.#{n+1}.erase_to", link_to(id, erase, n+1)
        poem.set_value "versions.#{n+1}.j_erase_to", ''
        poem.set_value "versions.#{n+1}.star", (n+1) == epage.version ? '*' : ''
      end
      poem.set_value "versions.#{mods+1}.promote", '_' # overwrite latest to do nothing
      poem.set_value "versions.#{mods+1}.erase_to", '_' # ditto
      
      # timeless, shrouded in the mists of time
      poem.set_value "versions.1.number", 1
      poem.set_value "versions.1.created_at", epage.created_at ? (strip_tz_offest epage.created_at) : "unknown"
      poem.set_value "versions.1.mod", "initial version"
      poem.set_value "versions.1.promote", link_to(id, promote, 1)
      poem.set_value "versions.1.j_promote", ''
      poem.set_value "versions.1.revert_to", (1 == epage.version ? '_' : link_to(id, revert, 1))
      poem.set_value "versions.1.j_revert_to", ''       
      poem.set_value "versions.1.erase_to", link_to(id, erase, 1)
      poem.set_value "versions.1.j_erase_to", ''
      poem.set_value "versions.1.star", 1 == epage.version ? '*' : ''

      poem.dump
      @title = 'go back in time baby!'
      poem.set_value "title", epage.title
      render(:history) {poem}
    rescue => e
      # let_the_user_know {e}
      $L.error {e}
      flash.alert {e}
      return redirect R(YPoet::Controllers::EpageN, id)
    end
  end
  
  class EpageMoveXX
    def post(source,target)
      EPoem.move_to_folder( source, target )
      redirect Landing
    end
  end
  
  class Landing
    
    # example of making a key last, would be better to reorder the Ruby hash
    def transform_to_hdf(tree, allow_drag = true)
      h = Neo::Hdf.new
      delay = nil
      trash_key = nil
      tree.each do |p|
        key = p[0]
        val = p[1]
        kind = val[:kind]
        s_label = val[:s_label]
        #binding.pry
        if kind == EPoem.folder_kind
          if s_label == "Trash"
            @has_a_trash = true
            #binding.pry
            trash_key = key
            #$stderr.puts "+trash_key "+trash_key.to_s
            delay = Proc.new do |k|
              # key is what key was when bound?
              #$stderr.puts "+key "+key.to_s
              GetText::set_locale(@language) # is 'xx' ... obviously the more specific the better, but fuck it
              h.set_value "#{k}.id", k
              h.set_value "#{k}.kind", kind
              trash_label = GetText::_("Trash")
              h.set_value "#{k}.s_label", trash_label
              h.set_value "#{k}.label", trash_label.gsub(/ /,"&nbsp;")
              next_allow_drag = false
              folder = val[:folder]
              f = transform_to_hdf(folder, next_allow_drag)
              h.copy "#{k}.folder", f
              #pp folder
            end
          else
            #$stderr.puts "-key "+key.to_s
            h.set_value "#{key}.id", key
            h.set_value "#{key}.kind", kind
            h.set_value "#{key}.s_label", s_label
            h.set_value "#{key}.label", s_label.gsub(/ /,"&nbsp;")
            h.set_value "#{key}.draggable", "drag_me"
            h.set_value "#{key}.drop_on_able", "drop_on_me"
            h.set_value "#{key}.unrestricted", true
            next_allow_drag = true
            folder = val[:folder]
            f = transform_to_hdf(folder, next_allow_drag)
            h.copy "#{key}.folder", f
            #pp folder
          end
        else
          case kind
            when 1
              #h.set_value "#{key}.controller", "epage/singular"
              h.set_value "#{key}.symbol", "†"
            when 2
              #h.set_value "#{key}.controller", "epage/reverse"
              h.set_value "#{key}.symbol", "‡"
            when 3
              #h.set_value "#{key}.controller", "epage/multiverse"
              h.set_value "#{key}.symbol", "§"
            when 4
              #h.set_value "#{key}.controller", "epage/traceverse"
              h.set_value "#{key}.symbol", "¶"
          end
          h.set_value "#{key}.id", key
          h.set_value "#{key}.kind", kind
          h.set_value "#{key}.s_label", s_label
          h.set_value "#{key}.draggable", "drag_me" if allow_drag
          h.set_value "#{key}.unrestricted", true if allow_drag
          h.set_value "#{key}.label", s_label.gsub(/ /,"&nbsp;")
        end
      end
      delay.call(trash_key) if delay
      h
    end
    
    def fill_hdf(p)
      x = EPoem.read_from_db(p)
      #pp x
      y = transform_to_hdf x
      #print y.dump
      y  
    end
    
    def admin
      if @p.unique_id == "92dae58c93ce1cd9cf5728f8b02b955a392bcc64b89ad8d8a4200bbbb9e04c61"
        $L.debug "admin goodness"
        return true
      end
      return false
    end
    
    def get
      @has_a_trash = false
      @title = "Poetify Loves You Very Much"
      @poetify_hd = Neo::Hdf.new
      @poetify_hd.copy "Epages", fill_hdf(@p)
      #binding.pry
      if @has_a_trash
        @poetify_hd.set_value 'has_a_trash', "yes" 
      else
        @poetify_hd.set_value 'has_a_trash', "no"
      end
      if admin
        @poetify_hd.set_value 'admin', true
      end
      @poetify_hd.set_value "VERSION", "0.3.a"
      @poetify_hd.set_value "drop_on_able", "drop_on_me"
      @poetify_hd.set_value "unrestricted", true
      @poetify_hd.set_value "Poetify.description", IO.read('/var/www/localhost/htdocs/README.html') # red_or_dead('/var/www/localhost/htdocs/README.markdown')
      @poetify_hd.set_value "lang", @language
      #t = "&nbsp;" + Time.now.to_s
      t = '&nbsp;<a href="" onclick="javascript:return close_alert();">x</a>'
      @poetify_hd.set_value "notice", env['x-rack.flash'].notice + t if env['x-rack.flash'].has? :notice
      @poetify_hd.set_value "alert",  env['x-rack.flash'].alert + t if env['x-rack.flash'].has? :alert
      render :internal_index
    end
    
    # these need to have their own fucking controllers
    def put # rename folder, double check pad 
      pp @input
      pp
      params = @input
      pp params[EPoem::NEW_OBJECT].inspect
      pp params[EPoem::THE_ID].inspect
      # NEW_OBJECT is the name the user has chosen
      EPoem.rename_folder( params[EPoem::NEW_OBJECT], params[EPoem::THE_ID] )
      redirect Landing      
    end

    # these need to have their own fucking controllers    
    def post
      pp @input
      pp
      params = @input
      pp params[EPoem::SUBMIT].inspect
      pp params[EPoem::NEW_OBJECT].inspect
      pp params[EPoem::PARENT_ID].inspect
      # NEW_OBJECT is the name the user has chosen
      if params[EPoem::SUBMIT] == EPoem::NEW_PAGE
        pp params[EPoem::NEW_KIND].inspect
        EPoem.create_epage( @p, params[EPoem::NEW_OBJECT], params[EPoem::PARENT_ID], params[EPoem::NEW_KIND] )
      else
        EPoem.create_folder( @p, params[EPoem::NEW_OBJECT], params[EPoem::PARENT_ID] )
      end
      redirect Landing
    end
    
    # DO DELETE HERE !!! (should be on Epage controller though =| )
    def delete # delete folder, double check pad
      pp @input
      pp
      params = @input
      pp params[EPoem::THE_ID].inspect
      EPoem.delete_folder( params[EPoem::THE_ID] )
      redirect Landing
    end
  end
  
  class PlayN
    # it's a PUT because it is idempotent for the mo' cuz of the messy URI business
    def put(id)
      @input.ePoem_id = id
      poem_type = @input.ePoem_type
      @e_poem_module = EPoem.type(poem_type) # use it :)
      PlayN.send(:include, @e_poem_module)
      render @e_poem_module::render
    end
  end
  
  #
  # i have no idea what i'm testing here
  #
  class Test
    def get
      render :some_hdf
    end
  end
  
  class TemplateX
    def get(t)
      render(t.to_sym, @input) { Neo::Hdf.new }
    end
  end
  
  class CatchRelativePath < R("([^/].+)")
    def get(path)
      # and others surely, tilt must handle them for our proj
      if path.ends_with?(".cshtml", ".html", ".rhtml", ".erb")
        pos = path =~ /(\.cshtml)|(\.html)|(\.rhtml)|(\.erb)$/ # how to do this metaproggy?
        v = path[0..pos-1]
      else
        v = path
      end
      t = lookup(v)
      if t
        s = (t == true) ? mab{ send(v) } : t.instance_variable_get(:@data)
        # no :layout for these
        s
      else
        raise "no include template: #{path}"
      end
    end
  end
  
  # can i put these into Tarpaulin???
  class Dyn < R ''
    
    def self.urls
      # capture starts with / then followed by one or more of anything but forward slash
      endless_path("/([^/]+)",1)
    end
    
    require 'mime/types'

    def file_name(first, *rest)
      fqfn = File.join(document_root, first, rest)
      mime_type = MIME::Types.type_for(fqfn).first 
      @headers['Content-Type'] = mime_type.nil? ? "text/plain" : mime_type.to_s
      if fqfn.include? ".." or fqfn.include? "./"
        r403 { fqfn } # these are logged
      elsif !File.exists? fqfn
        r404 { fqfn } # ''
      else
        # how to cache these?
        # $L.debug fqfn # get system to log it :(
        @headers['X-Sendfile'] = fqfn.to_s # this aint, why not?
      end
    end
    
    def get(first, *rest)
      file_name(first, *rest)
    end
    
    def post(*unsupported)
      binding.pry
      raise "unsupported verb in dyno-boy!!"
    end
    
  end
end

module YPoet::Views
  
    def layout
    
    comments = []
    comments << '[if lt IE 7]> <html class="no-js ie6 oldie" lang="en"> <![endif]'
    comments << '[if IE 7]>    <html class="no-js ie7 oldie" lang="en"> <![endif]'
    comments << '[if IE 8]>    <html class="no-js ie8 oldie" lang="en"> <![endif]'
    comments << '[if gt IE 8]><!'
    html_five({:class => "no-js", :lang => @language}, comments) do
      
      # how to simply get which controller we came from?
      comment! '<![endif]'
      
      head do
        meta "http-equiv" => "X-UA-Compatible", "content" => "IE=edge,chrome=1"
        
        title @title
        meta "name" => "description", "content" => "The Electronic Poetry Publishing Platform"
        meta "name" => "author", "content" => "Anthony Durity"
        
        meta "name" => "viewport", "content" => "width=device-width,initial-scale=1"

        link "rel" => "Stylesheet", "href" => "/cascading_stylesheets/poetify.css", "type" => "text/css"
        
        link "type" => "text/css", "href" => "/cascading_stylesheets/3rd-party/custom-theme-cupertino/jquery-ui-cupertino-1.8.16.custom.css", "rel" => "Stylesheet"
        # <link type="text/css" href="css/themename/jquery-ui-1.8.16.custom.css" rel="Stylesheet" />
        
        # javascript_link_tag "//ajax.googleapis.com/ajax/libs/jquery/1.7/jquery.min.js"
        # script "src" => "//ajax.googleapis.com/ajax/libs/jquery/1.7/jquery.min.js" do
        # end
        # script do
        #   text "window.jQuery || document.write('<script src=\"/javascripts/3rd-party/jquery-1.7.min.js\"><\\/script>')"
        # end
        # javascript_link_tag "//ajax.googleapis.com/ajax/libs/jqueryui/1.8.16/jquery-ui.min.js""
        script "src" => "/javascripts/3rd-party/jquery-1.7.min.js" do
        end
        script "src" => "/javascripts/3rd-party/jquery-ui-cupertino-1.8.16.custom.min.js" do
        end
        script "src" => "/javascripts/3rd-party/modernizr-2.0.6.min.js" do
        end
      end
      body do
        div.container! do
          header do
          end
          div.main!(:role => "main") do
            self << yield
          end
          footer do
          end
        end
        
        comment! '! end of #container '

        comment!  '[if lt IE 7 ]>'+
                  '<script src="//ajax.googleapis.com/ajax/libs/chrome-frame/1.0.2/CFInstall.min.js"></script>'+
                  '<script>window.attachEvent("onload",function(){CFInstall.check({mode:"overlay"})})</script>'+
                  '<![endif]'

      end # end body
    end # end html
  end # end layout
  
  def internal_index
    #print @poetify_hd.dump
    render(:index, {:locals => lingua, :layout => false}) do
      @poetify_hd
    end
  end
  
  def some_hdf 
    render( :user, {:layout => false} ) do
      h1=Neo::Hdf.new
      h1.set_value "user.name", "bob"
      h1.set_value "user.face", 3
      h1
    end
  end
  
  def foo
    "+++\n"
  end
  
end

module YPoet
  
  # TheApp.create is only called once per Camping invocation (lifetime of App)
  # so only put per-app invocation stuff here like db connections and config File reading
  def self.create
    self.required_reading
    YPoet::Models.create_schema
    EPoem.autoload
  end

end

#
# this does nothing in Camping server/console, just needed for pure Rack Apps?
#

case ENV['RACK_ENV']
  when 'development'
    # set a mode var?
    $L.info { "i'm in rack dev mode" }
    ENV['MODE'] = 'development'
  when 'production'
    # set a mode var?
    $L.info { "i'm in rack live mode" }
    ENV['MODE'] ||= 'production'
    run LayItOut
  else
    ENV['MODE'] = nil
end

if __FILE__ == $0
  # this library may be run as a standalone script
  # as in -> ruby rack_apps/zpoet/config.ru
  # dunno why you'd want to do that but anyway
  
  # set a mode var?
  $L.info { "i'm in standalone mode" }
  ENV['MODE']='standalone'
end