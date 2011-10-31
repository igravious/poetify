
#$DEBUG=true

%w{rubygems pry camping camping/session tarpaulin rack-flash}.each{|g| require g}

#now we have the logger, set the program name
$L.progname = "SanSan"
$L.debug "Current working directory is: "+Dir.getwd
Neo::Cs.bindtextdomain "poetify", Dir.getwd+"/locale"

Camping.goes :YPoet

# you #include stuff to mix it in
# you #use stuff to chain a middleware
module YPoet
  include CampingFlash # must go first
  include CampingFilters
  
  use( Rack::Flash, :flash_app_class => self, :accessorize => [:notice, :alert] ) # Camping invocation of rack-flash
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

module YPoet::Helpers
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
    $stderr.puts "+++ 1"
    redirect R(YPoet::Controllers::DoYouCookie)+"?referer=#{@env['PATH_INFO']}"
    throw :halt, self
    $stderr.puts "+++ 2"
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
  before :all do
    #require 'gettext'
    #need true gettext C ext for Ruby
    #GetText::set_locale('it_IT.UTF-8')
    #GetText::bindtextdomain('poetify', :path => Dir.getwd+'/locale')
    #GetText::textdomain('poetify')
    #$L.debug self.class.to_s.light_red
    #$L.debug @env['PATH_INFO'].to_s.light_red
    #$L.debug @env['HTTP_COOKIE'].red
    
    # skip the catch all class
    next if self.class == YPoet::Controllers::Dyn # use next instead of return cuz of Thread/Proc error
    #pad_helper_session
    perm_pad
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

  def self.add_ruby_and_co_to_library_load_path path_to_ruby #:nodoc:
    $:.unshift(path_to_ruby) if !$:.include?(path_to_ruby)
    path_to_ruby = File.join(path_to_ruby,"1.8")
    $:.unshift(path_to_ruby) if !$:.include?(path_to_ruby)
  end
  
  @@loaded = false # um, should this be self. or @@ :(

  #i do not understand this in relation to self.create in Camping
  #@@path_to_ruby = ''

  def self.required_reading
    if !@@loaded
      @@loaded = true
      yml = self.gimme_yml
      path_to_ruby = yml['locations']['vendor_ruby']
      self.add_ruby_and_co_to_library_load_path path_to_ruby
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
  class Index # RegexpError: regular expression too big:
    def get
      "try /landing or /another\n"
    end
  end
  
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
  
  # http://travisonrails.com/2008/08/17/working-with-the-flash-hash
  # flash.now[] before a render
  # flash[] before a redirect
  
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
  
  class Borked
    def post
      raise "raised a generic error"
    rescue => e
      env['x-rack.flash'].alert = e.message # should pass in e and have the flash print dev e.message or friendly user message
      flash[:notice] = "This really is a pain in the neck" # nice, flash works ...
      @state.foo = 3.14
      $L.error { e.message } # should pass in e and have the logger decide whether backtrace is printed or not
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
      case epage[:kind]
        when 1
          v = :singular
        when 2
          poem0 = ""
          if !epage[:body].nil? and !epage[:body][:poem0].nil? and !epage[:body][:poem0].empty?
            poem0 = epage[:body][:poem0]
          end
          poem.set_value "poem0", poem0
          poem1 = ""
          if !epage[:body].nil? and !epage[:body][:poem1].nil? and !epage[:body][:poem1].empty?
            poem1 = epage[:body][:poem1]
          end
          poem.set_value "poem1", poem1
          v = :reverse
        when 3
          v = :multiverse
        when 4
          v = :traceverse
      end
      render(v) { poem }
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
      # set correct href, action, src using CS
      redirect R(self.class, @id)
      # redirect R(YPoet::Controllers::EpageN, @id)
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

      mods.downto(1) do |n|
        poem.set_value "versions.#{n+1}.number", (n+1)
        poem.set_value "versions.#{n+1}.created_at", (strip_tz_offest epage.versions[n-1].created_at)
        poem.set_value "versions.#{n+1}.mod", (mods==n ? "latest version" : "modification")
        poem.set_value "versions.#{n+1}.promote", link_to(id, YPoet::Controllers::EpagePromoteN, n+1)
        poem.set_value "versions.#{n+1}.j_promote", ''
        poem.set_value "versions.#{n+1}.revert_to", (epage.version==n+1 ? '_' : link_to(id, YPoet::Controllers::EpageRevertToN, n+1))
        poem.set_value "versions.#{n+1}.j_revert_to", ''
        poem.set_value "versions.#{n+1}.erase_to", link_to(id, YPoet::Controllers::EpageEraseToN, n+1)
        poem.set_value "versions.#{n+1}.j_erase_to", ''
        poem.set_value "versions.#{n+1}.star", (n+1) == epage.version ? '*' : ''
      end
      poem.set_value "versions.#{mods+1}.promote", '_' # overwrite latest to do nothing
      poem.set_value "versions.#{mods+1}.erase_to", '_' # ditto
      
      poem.set_value "versions.1.number", 1
      poem.set_value "versions.1.created_at", epage.created_at ? (strip_tz_offest epage.created_at) : "unknown" # timeless, shrouded in the mists of time
      poem.set_value "versions.1.mod", "initial version"
      poem.set_value "versions.1.promote", link_to(id, YPoet::Controllers::EpagePromoteN, 1)
      poem.set_value "versions.1.j_promote", ''
      poem.set_value "versions.1.revert_to", (1 == epage.version ? '_' : link_to(id, YPoet::Controllers::EpageRevertToN, 1))
      poem.set_value "versions.1.j_revert_to", ''       
      poem.set_value "versions.1.erase_to", link_to(id, YPoet::Controllers::EpageEraseToN, 1)
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
  
  class Landing

    def transform_to_hdf(tree)
      h = Neo::Hdf.new
      tree.each do |p|
        key = p[0]
        val = p[1]
        epage_id = key
        kind = val[:kind]
        s_label = val[:s_label]
        h.set_value "#{key}.id", key
        h.set_value "#{key}.kind", kind
        h.set_value "#{key}.s_label", s_label
        h.set_value "#{key}.label", s_label.gsub(/ /,"&nbsp;")
        #pp key
        #pp val
        if kind == EPoem.folder_kind
          folder = val[:folder]
          f = transform_to_hdf(folder)
          h.copy "#{key}.folder", f
          #pp folder
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
        end
      end
      #pp h
      #print h.dump
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
        $L.debug "admin goodnes"
        return true
      end
      return false
    end
    
    def get
      @title = "Poetify Loves You Very Much"
      @poetify_hd = Neo::Hdf.new
      @poetify_hd.copy "Epages", fill_hdf(@p)
      if admin
        @poetify_hd.set_value 'admin', true
      end
      @poetify_hd.set_value "VERSION", "0.3.a"
      @poetify_hd.set_value "Poetify.description", red_or_dead('/var/www/localhost/htdocs/README.markdown')      
      @poetify_hd.set_value "notice", env['x-rack.flash'].notice + "&nbsp;" + Time.now.to_s if env['x-rack.flash'].has? :notice
      @poetify_hd.set_value "alert",  env['x-rack.flash'].alert +  "&nbsp;" + Time.now.to_s if env['x-rack.flash'].has? :alert
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
      if path.ends_with?(".cshtml", ".html", ".rhtml", ".erb") # and others surely, tilt must handle them for our proj
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
      endless_path("/([^/]+)",1) # capture starts with / then followed by one or more of anything but forward slash
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
      raise "unsupported verb"
    end
    
  end
  
  Tarpaulin.link_controller = YPoet::Controllers::Dyn
end

module YPoet::Views
  
  def layout
    html_five do
      # how to simply get which controller we came from?
      head do
        title @title
        javascript_link_tag 'https://www.google.com/jsapi?key=ABQIAAAAUzJ_6UqPfuuygp9Xo0AGoxRYjYHH-N6Ytftz1YKT8IaSgMm3fBSIC090wMAgB4Mcecyj6FsiJdo98g'
        
        javascript_link_tag 'https://ajax.googleapis.com/ajax/libs/jquery/1.5/jquery.min.js'

        stylesheet_link_tag 'poetify'
      end
      body do
        self << yield
        # rb info or it didn't happen
        #methods.sort.each do |m_var|
        #  pre m_var
        #end
      end # end body
    end # end html
  end # end layout
  
  def internal_index
    #print @poetify_hd.dump
    render(:index, {:locals => {:locale => 'it_IT.UTF-8'}, :layout => false}) do
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
