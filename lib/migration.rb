require "../config/environment" unless defined?(::Rails.root)

MAXWIKI_DB = ""
MAXWIKI_USER = ""
MAXWIKI_PWD = ""
MAXWIKI_STORE = ""
MAXWIKI_WIKI = 

ME_USERID = 
ME_SITE = ''

ActiveRecord::Base.establish_connection(
  :adapter  => "mysql",
  :host     => "localhost",
  :username => MAXWIKI_USER,
  :password => MAXWIKI_PWD,
  :database => MAXWIKI_DB
)

pages = ActiveRecord::Base.connection.execute("select id, name from pages where wiki_id = #{MAXWIKI_WIKI} ")

new_pages = []
pages.each do |page|

  page_id = page[0]
  page_name = page[1]
  sql = "select content from revisions where page_id = #{page_id} order by revised_at desc limit 1;"
  res = ActiveRecord::Base.connection.execute( sql )
  content = res.first[0]

  # 
  # default page on MaxWiki is HomePage, on ME it's 'index'
  #
  page_name.gsub!( /HomePage/, 'index' )
  content.gsub!( /HomePage/, 'index' )

  # 
  # storage locations
  # 
  content.gsub!( /\/files\/attachments\/#{MAXWIKI_STORE}/ , "/storage/"+ME_SITE )

  #
  # embedded ruby
  # 
  content.gsub!( /<%(.*?)%>/ , '<!--\1*-->' )

  #
  # page links
  #
  content.gsub!( /<li><a\s*?class="existing_page_link"\s*?href="\/">(.*?)<\/a>\s*?<\/li>/, 
             '<%= pagelink index, \2 %>' )
  content.gsub!( /<li><a\s*?class="existing_page_link"\s*?href="\/(.*?)">(.*?)<\/a>\s*?<\/li>/, 
             '<%= pagelink \1, \2 %>' )
  content.gsub!( /<div(\s+)class="role_Admin"(\s+)style="display:(\s+)none"><a(\s+)href="\/_action\/reg_admin">(\s*)Admin(\s*)<\/a>(\s*)<\/div>/, '')

  puts "INSERT INTO pages (name, content, user_id,site )
   VALUES( \"#{page_name}\", \"#{Mysql.escape_string(content)}\", #{ME_USERID}, \"#{ME_SITE}\" );"

end
eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6IjEifQ