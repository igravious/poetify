#!/usr/bin/env ruby
# get_epages.cgi

# ruby sqlite3 - it's all here - _all_ here
# http://sqlite-ruby.rubyforge.org/sqlite3/faq.html

# UGLY, IMPERFECT -- BUT FUNCTIONAL

#new_object = "NewObject"
#new_page = "New Page!"
#new_folder = "New Folder!"
 
print <<-PREAMBLE
Content-type: text/html

<script type='text/javascript' src='https://www.google.com/jsapi?key=ABQIAAAAUzJ_6UqPfuuygp9Xo0AGoxRYjYHH-N6Ytftz1YKT8IaSgMm3fBSIC090wMAgB4Mcecyj6FsiJdo98g' > </script>
<script src='https://ajax.googleapis.com/ajax/libs/jquery/1.5/jquery.min.js'> </script>
<script src='/js/file-folder-utilities-0.1.js'> </script>
<div style='border: 1px solid #808080; background:white; position: absolute; display: none;' id='file-folder'>
<!-- menu stuff in here, only when you hover over the file or folder should the menu down arrow appear -->
<!-- pressing ESC should make it disappear -->
<br>
<form name='superFolder' action='get_epages.cgi' method='post'>
<input id='' class='' name='NewObject' type='text' value=''/>
<input id='' class='' name='EpageID' type='hidden' value=''/>
<!-- check for non-null string before clicking -->
<input id='' class='' name='Submit' type='submit' value='New Folder!'/>
</form>
<br>
<form name='superPage' action='get_epages.cgi' method='post'>'
<input id='' class='' name='NewObject' type='text' value=''/>
<input id='' class='' name='EpageID' type='hidden' value=''/>
<!-- check for non-null string before clicking -->
<input id='' class='' name='Submit' type='submit' value='New Page!'/>
<select name='EpageTYPE'>
<option value="1:verse">Singular-Verse</option>
<option value="2:verse">Re-Verse</option>
<option value="n:verse">Multi-Verse</option>
<option value="woven:verse">Woven-Verse</option>
</select>
</form>
Cool Menu Stuff <span id='custom-stuff'></span>
</div>
PREAMBLE

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
							puts "<li> ePage :: <a href='/work_on_singular.html?id=#{epage_id}&name=#{label}'>#{label}</a> </li>"
						when 2
							puts "<li> ePage :: <a href='/work_on_reverse.html?id=#{epage_id}&name=#{label}'>#{label}</a> </li>"
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
			pre boom.backtrace
			puts "<div>i said urk</div>"
		end
	end
	
	def pre obj
		puts "<pre class='ruby_output'>#{CGI.escapeHTML(obj.inspect)}</pre>"
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
			pre boom.backtrace
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
		puts "<div>the kind is #{the_kind}</div>"
		the_kind = POEM_TYPES[the_kind.to_sym]
		puts "<div>the kind really is #{the_kind}</div>"

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
			pre boom.backtrace
			puts "<div>i said urk</div>"
		end
	end

	require 'cgi'
	cgi = CGI.new
	puts "<h2>ePages #{cgi.request_method}</h2>"
	
	puts '<div style="width: 300px; padding: 20px; border: 1px solid #808080">'
	
	@db = SQLite3::Database.new( "poetify.db" )
	
	params = cgi.params
	#p params
	# these should be CONSTANTS and used in the HERE DOC as well
	new_object = "NewObject"
	new_page = "New Page!"
	new_folder = "New Folder!"
	parent_id = "EpageID"
	new_kind = "EpageTYPE"
	
	if cgi.request_method == "POST"
		# create new ePage or create new folder ?
		if params["Submit"].first == new_page
			create_epage( params[new_object].first, params[parent_id].first, params[new_kind].first )
		else
			create_folder( params[new_object].first, params[parent_id].first )
		end
	else
	end
	
	#puts '<br>'
	#puts '<form action="get_epages.cgi" method="post">'
	#puts '<input id="" class="" name="' +new_object+ '" type="text" value=""/>'
	#puts '<input id="" class="" name="Submit" type="submit" value="' +new_folder+ '"/>'
	#puts '</form>'

	puts '<ul class="tree">'
	paint_tree nil
	puts '</ul>'
	
	#puts '<br>'
	#puts '<form action="get_epages.cgi" method="post">'
	#puts '<input id="" class="" name="' +new_object+ '" type="text" value=""/>'
	#puts '<input id="" class="" name="Submit" type="submit" value="' +new_page+ '"/>'
	#puts '</form>'
	
	puts '</div>' 
	
rescue => bang
	puts "Error running script: " + bang + "<br>"
	trace = bang.backtrace
	puts trace.join("<br>")
end
