require "../config/environment" unless defined?(::Rails.root)

ActiveRecord::Base.establish_connection(
  :adapter  => "mysql",
  :host     => "localhost",
  :username => "rails",
  :password => "activerecord23",
  :database => "maxwiki_prod"
)

pages = ActiveRecord::Base.connection.execute("select id, name from pages where wiki_id = 39 ")

new_pages = []
pages.each do |page|
  page_id = page[0]
  page_name = page[1]
  page_name.gsub!( /HomePage/, 'index' )
  sql = "select content from revisions where page_id = #{page_id} order by revised_at desc limit 1;"
  content = ActiveRecord::Base.connection.execute( sql )
  puts "INSERT INTO pages (name, content, user_id,site )
   VALUES( \"#{page_name}\", \"#{Mysql.escape_string(content.first[0])}\", 13, 'trixi.menhardt.com');"
end
