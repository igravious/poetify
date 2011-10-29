
require File.here "poetify/epoem"
require File.here "poetify/form_post"

require 'active_support'
require 'vestal_versions'

class EPage < ActiveRecord::Base # do we need to establish the connection first, or is ActiveRecord flexible enough?
	serialize :body
	set_table_name "ePages"
	set_primary_key :epage_id
	versioned
	
	def self.enable_versioning
	end
	
  def self.disable_versioning
    # how? for unwinding migrations - irreversible for now
  end
end

class PoemPad < ActiveRecord::Base
  set_table_name "PoemPads"  
  set_primary_key :pad_id
end

class KindConstant < ActiveRecord::Base # yes we do, is the short answer
	set_table_name "KindConstants"
	set_primary_key :kind
end

class TreePath < ActiveRecord::Base
  set_table_name "TreePaths"
end

require 'colorize'

class EPoem
  
  # sub into epages.cshtml
  # should i ever do a epages.cshtml.erb ???
  SUBMIT="Submit"
  NEW_OBJECT = "NewObject"
  NEW_PAGE = "New Page!"
  NEW_FOLDER = "New Folder!"
  THE_ID = "EpageID"
  PARENT_ID = "EpageID"
  NEW_KIND = "EpageTYPE"
  
  @@db = nil # for straight to db ops, should use activerecord solely though?
  
  def self.db
    return @@db
    # :(
    # require 'yaml'
    # yml = YAML::load_file('.poetifyrc')
    # require 'active_record'
    # a = ActiveRecord::Base.establish_connection(yml['locations']['database_connection'])
    # ActiveRecord::Base.connection.methods.sort
    # ActiveRecord::Base.connection
  end
  
  def self.init_db config
    require 'sqlite3'
    @@db = SQLite3::Database.new( config['locations']['database_connection']['database'] )
    @@db.execute('PRAGMA foreign_keys = ON')
    @@db.busy_timeout 1000 # try for 1 second, use a real db anto, ok for dev mode :)
    @@db.trace {|sql| $L.debug "  Tracing SQL (?)  ".yellow + sql.to_s.light_white}
    # :(
  end

	# set the correct Module to autoload
	def self.autoload
		# db connection has been made by now presumably
		KindConstant.all.each do |kind_const|
			#$stderr.puts "the kind_const is #{kind_const}"
			the_module_sym = kind_const.klass_name
			#$stderr.puts "the sym is #{the_module_sym}"
			the_file = File.join('poetify',kind_const.klass_name.downcase)
			#$stderr.puts "the file is #{the_file}"
			Kernel.autoload the_module_sym, the_file
		end
	end
	
	# and give the desired Module to whoever wants it
	def self.type the_type # klass_name should be called const_name
		#$stderr.puts "the type is #{the_type}"
		kindly = KindConstant.find(the_type)
		#$stderr.puts "the kindly is #{kindly}"
		const_get(kindly.klass_name)
	end
	
	def self.top_folder
      "NULL"
  end
	
	def self.folder_kind
      -1
  end

  def self.rename_folder( the_folder, the_id ) # should all these be wrapped in rescues and such?
    begin        
      if the_id.nil? or the_folder.nil? or the_folder == '' 
        raise "can't rename that which is unrenameable"
      else
        where_clause = "WHERE t.parent_id = #{the_id}"
      end
  
      epage = EPage.find(the_id)
      # assert that it is a folder
      fail unless epage.kind == folder_kind
      EPoem.db.transaction
      # *rows = EPoem.db.execute( "UPDATE ePages SET label = '#{the_folder}' WHERE epage_id = #{the_id} LIMIT 1" )
      *rows = EPoem.db.execute( "UPDATE ePages SET label = '#{the_folder}' WHERE epage_id = #{the_id}" )
      EPoem.db.commit
    rescue => boom
      $L.error { boom }
    end
  end
    
  def self.delete_folder( the_id ) # should all these be wrapped in rescues and such?
    begin        
      if the_id.nil?
        raise "can't delete that which is undeleteable"
      else
        where_clause = "WHERE t.parent_id = #{the_id}"
      end
  
      tree = Hash.new
  
      columns, *rows = EPoem.db.execute2( "SELECT e.* FROM TreePaths t JOIN ePages e ON t.epage_id = e.epage_id #{where_clause}")
      # pp columns
      # pp rows
      # columns is unused
      # col_epage_id = columns.find_index("epage_id")
      # col_kind = columns.find_index("kind")
      # col_label = columns.find_index("label")
      pp rows
      if rows.length > 0
        raise "Folder is not empty!"
      else
        epage = EPage.find(the_id)
        # assert that it is a folder
        fail unless epage.kind == folder_kind
        EPoem.db.transaction
        begin
          *rows = EPoem.db.execute( "DELETE FROM TreePaths WHERE epage_id = #{the_id}" )
          *rows = EPoem.db.execute( "DELETE FROM ePages WHERE epage_id = #{the_id}" )
          EPoem.db.commit
        rescue => bang
          EPoem.db.rollback
          $L.error { boom }
        end
      end
    rescue => boom
      $L.error { boom }
    end
  end
	
	def self.create_folder( the_pad, the_folder, parent_id )
    #puts "<div>the label is #{the_folder}</div>"
    
    # label must not be nil and must be unique
    
    begin
      #pre Dir.getwd
      EPoem.db.transaction
      max_id = EPoem.db.get_first_row("SELECT MAX(epage_id) FROM ePages")[0]
      max_id = (max_id == nil ? 1 : max_id+1)
      columns, *rows = EPoem.db.execute2( "INSERT INTO ePages \
                      (epage_id, pad_id, label, kind) \
                      VALUES \
                      (:id, :pad_id, :label, :kind)",
                      :id => max_id,
                      :pad_id => the_pad.pad_id,
                      :label => the_folder,
                      :kind => folder_kind)
      parent_id = (parent_id == "undefined" ? nil : parent_id.to_s)
      columns, *rows = EPoem.db.execute2( "INSERT INTO TreePaths \
                      (parent_id, epage_id) \
                      VALUES \
                      (:parent_id, :next_id)",
                      :parent_id => parent_id,
                      :next_id => max_id)
      EPoem.db.commit
      #puts "<div>inserted folder</div>"
    rescue => boom
      EPoem.db.rollback
      # binding.pry
      $L.error { boom }
    end
  end
  
  # need a poem class and subclasses for sexiness
  
  POEM_TYPES = {
    :'1:verse' => 1,
    :'2:verse' => 2,
    :'n:verse' => 3,
    :'woven:verse' => 4
  }
  
  def self.create_epage( the_pad, the_page, parent_id, the_kind )
    #puts "<div>the label is #{the_page}</div>"
    #puts "<div>the kind is #{the_kind}</div>"
    the_kind = POEM_TYPES[the_kind.to_sym]
    #puts "<div>the kind really is #{the_kind}</div>"

    # label must not be nil and must be unique
    
    begin
      #pre Dir.getwd
      EPoem.db.transaction
      max_id = EPoem.db.get_first_row("SELECT MAX(epage_id) FROM ePages")[0]
      max_id = (max_id == nil ? 1 : max_id+1)
      columns, *rows = EPoem.db.execute2( "INSERT INTO ePages \
                      (epage_id, pad_id, label, kind) \
                      VALUES \
                      (:id, :pad_id, :label, :kind)",
                      :id => max_id,
                      :pad_id => the_pad.pad_id,
                      :label => the_page,
                      :kind => the_kind)
      parent_id = (parent_id == "undefined" ? nil : parent_id.to_s)
      columns, *rows = EPoem.db.execute2( "INSERT INTO TreePaths \
                      (parent_id, epage_id) \
                      VALUES \
                      (:parent_id, :next_id)",
                      :parent_id => parent_id,
                      :next_id => max_id)
      EPoem.db.commit
      #puts "<div>inserted label</div>"
    rescue => boom
      EPoem.db.rollback
      $L.error { boom }
    end
  end
  
  def self.read_from_db(p, node=nil)
    if node == nil
      where_clause = "WHERE e.pad_id = #{p.pad_id} AND t.parent_id IS NULL"
    else
      where_clause = "WHERE e.pad_id = #{p.pad_id} AND t.parent_id = #{node}"
    end
  
    tree = Hash.new
  
    columns, *rows = EPoem.db.execute2( "SELECT e.* FROM TreePaths t JOIN ePages e ON t.epage_id = e.epage_id #{where_clause}")
    # pp columns
    # pp rows
    col_epage_id = columns.find_index("epage_id")
    col_kind = columns.find_index("kind")
    col_label = columns.find_index("label")
    rows.each do |row|
      epage_id = row[col_epage_id]
      kind = row[col_kind]
      s_label = row[col_label]
      
      # pp tree
      tree[epage_id] = { :kind => kind, :s_label => s_label }
      # tree[:label] = label
      if kind == EPoem.folder_kind
        # recurse
        oo = read_from_db(p, epage_id)
        # pp oo
        tree[epage_id][:folder] = oo
        # pp tree
      end
    end
    tree
  end

end