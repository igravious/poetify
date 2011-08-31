#!/usr/bin/env ruby
# get_epages.cgi

# ruby sqlite3 - it's all here - _all_ here
# http://sqlite-ruby.rubyforge.org/sqlite3/faq.html
 
begin

	require 'rubygems'
	require 'sqlite3'

	puts "Content-type: text/html"
	puts
	
	puts '<h2>ePages</h2>'
	puts '<div style="width: 300px; padding: 20px; border: 1px solid #808080">'
	puts '<ul class="tree">'

	db = SQLite3::Database.new( "poetify.db" )
	columns, *rows = db.execute2( "select * FROM ePages WHERE epage_id NOT IN (SELECT DISTINCT t.ancestor 
FROM TreePaths t JOIN TreePaths x ON (x.descendant = t.ancestor) WHERE x.ancestor != x.descendant)")

	col_type = columns.find_index("type")
	col_label = columns.find_index("label")
	rows.each do |row|
		if row[col_type]
			puts "<li> ePage :: #{row[col_label]} </li>"
		else
			# recurse
			puts "<ul> Folder :: #{row[col_label]} </ul>"
		end
	end
	
	puts '</ul>' 
 	puts '</div>' 
	
rescue => bang
	puts "Content-type: text/html"
        puts
        puts "Error running script: " + bang + "<br>"
        trace = bang.backtrace
        puts trace.join("<br>")
end
