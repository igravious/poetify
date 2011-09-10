
puts "<script src='/js/file-folder-utilities-0.1.js'> </script>" # should make .rjs (NewObject, EpageID)
require 'erb'
file_folder = ERB.new(File.read('super_duper.rhtml'))
NEW_OBJECT = "NewObject"
NEW_PAGE = "New Page!"
NEW_FOLDER = "New Folder!"
PARENT_ID = "EpageID"
NEW_KIND = "EpageTYPE"
html_str = file_folder.result(binding)
puts html_str

begin

	require 'rubygems'
	require 'sqlite3'
	
	def paint_tree node
		
		begin
			if node == nil
				where_clause = "WHERE t.parent_id IS NULL"
				puts "<div><img id='the-image' src='/images/down-arrow.png'></div>"
				puts "<script>$('#the-image').toggle(superMenuIn, superMenuOut);</script>"
			else
				where_clause = "WHERE t.parent_id = #{node}"
			end
			
			columns, *rows = @db.execute2( "SELECT e.* FROM TreePaths t JOIN ePages e \
										ON t.epage_id = e.epage_id \
										#{where_clause}")
			#pre columns
			#pre rows
			col_epage_id = columns.find_index("epage_id")
			col_kind = columns.find_index("kind")
			col_label = columns.find_index("label")
			rows.each do |row|
				epage_id = row[col_epage_id]
				kind = row[col_kind]
				label = row[col_label]
				if kind == folder_kind
					# recurse
					puts "<li>"
					puts "<span> Folder :: #{label} <img id='the-image-#{epage_id}' src='/images/down-arrow.png'></span>"
					puts "<script>$('#the-image-#{epage_id}').toggle(superMenuIn, superMenuOut);</script>"
					puts "<ul>"
					paint_tree epage_id
					puts "</ul>"
					puts "</li>"
				else
					case kind
						when 1
							puts "<li> ePage :: <a href='/cgi/test_work_on_singular.cgi?id=#{epage_id}&name=#{label}'>#{label}</a> </li>"
						when 2
							puts "<li> ePage :: <a href='/cgi/test_work_on_reverse.cgi?id=#{epage_id}&name=#{label}'>#{label}</a> </li>"
						when 3
							puts "<li> ePage :: <a href='/work_on_multiverse.html?id=#{epage_id}&name=#{label}'>#{label}</a> </li>"
						when 4
							puts "<li> ePage :: <a href='/work_on_traceverse.html?id=#{epage_id}&name=#{label}'>#{label}</a> </li>"
					end
				end
			end
		rescue => boom
			puts "<div>urk 1</div>"
			pre boom
			trace = boom.backtrace
			pre_s trace.join("\n")
			puts "<div>i said urk</div>"
		end
	end
	
	def pre obj
			puts "<pre class='ruby_output'>#{CGI.escapeHTML(obj.inspect)}</pre>"
	end
	
	def pre_s str
			puts "<pre class='ruby_output'>#{CGI.escapeHTML(str)}</pre>"
	end
		
	def folder_kind
		nil
	end
	
	def create_folder( the_folder, parent_id )
		#puts "<div>the label is #{the_folder}</div>"
		
		# label must not be nil and must be unique
		
		begin
			#pre Dir.getwd
			@db.transaction
			max_id = @db.get_first_row("SELECT MAX(epage_id) FROM ePages")[0]
			max_id = (max_id == nil ? 1 : max_id+1)
			columns, *rows = @db.execute2( "INSERT INTO ePages \
											(epage_id, label, kind) \
											VALUES \
											(:id, :label, :kind)",
											:id => max_id,
											:label => the_folder,
											:kind => folder_kind)
			parent_id = (parent_id == "undefined" ? nil : parent_id.to_s)
			columns, *rows = @db.execute2( "INSERT INTO TreePaths \
											(parent_id, epage_id) \
											VALUES \
											(:parent_id, :next_id)",
											:parent_id => parent_id,
											:next_id => max_id)
			@db.commit
			#puts "<div>inserted folder</div>"
		rescue => boom
			puts "<div>urk 3</div>"
			pre boom
			trace = boom.backtrace
			pre_s trace.join("\n")
			puts "<div>i said urk</div>"
		end
	end
	
	def default_kind
		1
	end
	
	# need a poem class and subclasses for sexiness
	
	POEM_TYPES = {
		:'1:verse' => 1,
		:'2:verse' => 2,
		:'n:verse' => 3,
		:'woven:verse' => 4
	}
	
	def create_epage( the_page, parent_id, the_kind )
		#puts "<div>the label is #{the_page}</div>"
		#puts "<div>the kind is #{the_kind}</div>"
		the_kind = POEM_TYPES[the_kind.to_sym]
		#puts "<div>the kind really is #{the_kind}</div>"

		# label must not be nil and must be unique
		
		begin
			#pre Dir.getwd
			@db.transaction
			max_id = @db.get_first_row("SELECT MAX(epage_id) FROM ePages")[0]
			max_id = (max_id == nil ? 1 : max_id+1)
			columns, *rows = @db.execute2( "INSERT INTO ePages \
											(epage_id, label, kind) \
											VALUES \
											(:id, :label, :kind)",
											:id => max_id,
											:label => the_page,
											:kind => the_kind)
			parent_id = (parent_id == "undefined" ? nil : parent_id.to_s)
			columns, *rows = @db.execute2( "INSERT INTO TreePaths \
											(parent_id, epage_id) \
											VALUES \
											(:parent_id, :next_id)",
											:parent_id => parent_id,
											:next_id => max_id)
			@db.commit
			#puts "<div>inserted label</div>"
		rescue => boom
			puts "<div>urk 2</div>"
			pre boom
			trace = boom.backtrace
			pre_s trace.join("\n")
			puts "<div>i said urk</div>"
		end
	end

	require 'cgi'
	cgi = CGI.new
	
	if $STANDALONE # should yield
		puts "<h2>ePages #{cgi.request_method}</h2>"
		puts '<div style="width: 300px; padding: 20px; border: 1px solid #808080">'
	end
	
	require 'yaml'
	# should be a symlink to the config file
	yml = YAML::load_file('.poetifyrc')

	#require 'rubygems'
	#require 'active_record'
	#ActiveRecord::Base.establish_connection(yml['locations']['database_connection'])
	@db = SQLite3::Database.new( yml['locations']['database_connection']['database'] )
	
	params = cgi.params
	#p ENV
	#p params
	# these should be CONSTANTS and used in the HERE DOC as well
	
	if cgi.request_method == "POST"
		# create new ePage or create new folder ?
		if params["Submit"].first == NEW_PAGE
			create_epage( params[NEW_OBJECT].first, params[PARENT_ID].first, params[NEW_KIND].first )
		else
			create_folder( params[NEW_OBJECT].first, params[PARENT_ID].first )
		end
	else
	end
	
	puts '<ul class="tree">'
	paint_tree nil
	puts '</ul>'
	
	puts '</div>' if $STANDALONE # should yield
	
rescue => bang
	puts "Error running script: " + bang + "<br>"
	trace = bang.backtrace
	puts trace.join("<br>")
end