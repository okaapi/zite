require 'test_helper'

class PageTest < ActiveSupport::TestCase
  
  setup do
    Rails.configuration.site = 'testsite'  
    ZiteActiveRecord.site( 'testsite' )
    @wido = User.find_by_username('wido_admin')
    # need to change <#= #> to <%= %> in fixtures
    pages = Page.all
    pages.each do |page|
      if page.content and /<#=/ =~ page.content      
        page.content = page.content.gsub(/<#=/,'<%=').gsub(/#>/,'%>') if page.content
        page.save!
      end  
    end
  end
  
  test 'nil content' do
    page = pages(:nil_page)
    assert_equal page.display, 'empty page'  
  end
  
  test 'visibilities and editabilities' do
    assert_equal Page.visibilities, ["any", "user", "editor", "self", "admin"]
    assert_equal Page.editabilities, ['admin', 'self', 'editor']
  end
  
  test 'test visibility for different users' do
    
    pages = []
    Page.visibilities.each do |v|
      Page.editabilities.each do |p|
        pages << Page.new( user_id: @wido.id, editability: p, visibility: v  )
      end
    end
    users = User.all
    users << nil
    users.each do |user|
      pages.each do |page|
        role = user ? user.role : nil              
        case role
        when nil
          case page.visibility
          when 'any'
            assert page.visible_by_user( role )
          else
            assert_not page.visible_by_user( role )
          end
        when 'user'
          case page.visibility
          when 'any', 'user' 
            assert page.visible_by_user( role )
          else
            assert_not page.visible_by_user( role )
          end
        when 'editor'
          case page.visibility
          when 'any', 'user', 'editor'
            assert page.visible_by_user( role )
          when 'self'
            assert page.visible_by_user( role, @wido.id )
          else
            assert_not page.visible_by_user( role )
          end          
        when 'admin'
          assert page.visible_by_user( role )      
        else
          assert_not true
        end               
      end
    end
    
  end
  
  test 'test editability for different users' do
    
    pages = []
    Page.visibilities.each do |v|
      Page.editabilities.each do |p|
        pages << Page.new( user_id: @wido.id, editability: p, visibility: v  )
      end
    end
    users = User.all
    users << nil
    users.each do |user|
      pages.each do |page|
        role = user ? user.role : nil              
        case role
        when nil
        when 'user'          
          assert_not page.editable_by_user( role )
        when 'editor'
          case page.editability
          when 'any', 'user', 'editor'
            assert page.editable_by_user( role )
          when 'self'
            assert page.editable_by_user( role, @wido.id )
          else
            assert_not page.editable_by_user( role )
          end          
        when 'admin'
          assert page.editable_by_user( role )      
        else
          assert_not true
        end               
      end
    end
    
  end  
  
  test 'test include' do
    page = Page.find_by_name( 'include')
    assert_equal page.content, "INCLUDE <%= include index %>"
    assert_equal page.display, "INCLUDE <h1> Index Page </h1>"
  end
  

  test 'test pagelink' do
     
    page = Page.find_by_name( 'pagelink')
    assert_equal page.content, "PAGELINK <%= pagelink index %>"
    assert_equal page.display, "PAGELINK <a href=\"/index\" class=\"pagelink\">index</a>" 
  
    page = Page.find_by_name( 'pagelink2')
    assert_equal page.content, "PAGELINK2 <%= pagelink index, link to index... %>"
    assert_equal page.display, "PAGELINK2 <a href=\"/index\" class=\"pagelink\"> link to index...</a>"
    
    page = Page.find_by_name( 'pagelink3')
    assert_equal page.content, 
         "PAGELINK3 <%= pagelink index %> SOME TEXT <%= pagelink index, link to index %>"
    assert_equal page.display, "PAGELINK3 <a href=\"/index\" class=\"pagelink\">index</a> SOME TEXT <a href=\"/index\" class=\"pagelink\"> link to index</a>"    
    
         
    page = Page.find_by_name( 'adminlink')
    assert_equal page.content, "ADMINLINK <%= adminlink admin %>"
    assert_equal page.display, "ADMINLINK "   
        
    page = Page.find_by_name( 'adminlink')
    assert_equal page.content, "ADMINLINK <%= adminlink admin %>"
    assert_equal page.display('admin'), "ADMINLINK <a href=\"/admin\" class=\"adminlink\">admin</a>"   
    
    page = Page.find_by_name( 'adminlink2')
    assert_equal page.content, "ADMINLINK2 <%= adminlink admin, stuff... %>"
    assert_equal page.display('admin'), "ADMINLINK2 <a href=\"/admin\" class=\"adminlink\"> stuff...</a>"      
        
  end  

  test 'test roles' do
    
    page = Page.find_by_name( 'admin' )
    assert_equal page.content, "ADMIN <%= admin  <h1> Admin Heading</h1> to 'admin stuff' %>"
    assert_equal page.display(  ), "ADMIN "
    
    page = Page.find_by_name( 'admin' )
    assert_equal page.content, "ADMIN <%= admin  <h1> Admin Heading</h1> to 'admin stuff' %>"
    assert_equal page.display( 'admin' ), "ADMIN <h1> Admin Heading</h1> to 'admin stuff'" 
    
    page = Page.find_by_name( 'editor')
    assert_equal page.content, "EDITOR <%= editor  <h1> Editor Heading</h1> to 'editor stuff' %>"
    assert_equal page.display, "EDITOR "   
    
    page = Page.find_by_name( 'editor')
    assert_equal page.content, "EDITOR <%= editor  <h1> Editor Heading</h1> to 'editor stuff' %>"
    assert_equal page.display( 'editor' ), "EDITOR <h1> Editor Heading</h1> to 'editor stuff'"      
        
    page = Page.find_by_name( 'editor')  
    assert_equal page.content, "EDITOR <%= editor  <h1> Editor Heading</h1> to 'editor stuff' %>"
    assert_equal page.display( 'admin' ), "EDITOR <h1> Editor Heading</h1> to 'editor stuff'" 
                
  end
  
  test 'test whole page' do

    header, menu, left, center, right, footer = Page.get_layout( 'index' )
    assert_equal header.name, 'index_header'
    assert_equal menu.name, 'index_menu'
    assert_equal left.name, 'index_left'
    assert_equal center.name, 'index'
    assert_equal right.name, 'index_right'
    assert_equal footer.name, 'index_footer'
    
    header, menu, left, center, right, footer = Page.get_layout( 'presentations' )
    assert_not header
    assert_not menu
    assert_not left
    assert_not right
    assert_equal footer.name, 'footer'      
           
    header, menu, left, center, right, footer = Page.get_layout( 'talks' )
    assert_not header
    assert_not menu
    assert_equal left.name, 'talks_left'
    assert_not right
    assert_equal footer.name, 'footer'
        
    header, menu, left, center, right, footer = Page.get_layout( 'talks_books' )
    assert_not header
    assert_not menu
    assert_equal left.name, 'talks_left'
    assert_not right
    assert_equal footer.name, 'footer'    
      
    header, menu, left, center, right, footer = Page.get_layout( 'talks_films' )
    assert_not header
    assert_not menu
    assert_equal left.name, 'talks_films_left'
    assert_not right
    assert_equal footer.name, 'footer'     

  end
  
  test 'css' do
    assert_equal Page.get_css, "{ color: red } "
  end
  
  test 'more panels' do
    assert_equal Page.get_panel( 'index', 'left').name, "index_left"
    assert_not Page.get_panel( 'presentations', 'left')
    assert_equal Page.get_panel_or_default( 'index', 'left').name, "index_left"
    assert_equal Page.get_panel_or_default( 'presentations', 'menu').name, "menu"
  end
  
  test 'display chronological' do 
   
    header, menu, left, center, right, footer = Page.get_layout( 'index' )    
    assert_equal center.content, '<h1> Index Page </h1>'
    assert_equal header.content, 'INDEX HEADER'
        
  end
  

  test 'imagelink' do
    page = Page.find_by_name( 'imagelink')
    assert_equal page.content, "IMAGELINK <%= imagelink lifebetterinflipflops.jpg %>"
    assert_equal page.display, "IMAGELINK <a href=\"/storage/imagelink/lifebetterinflipflops.jpg\"> <img src=\"/storage/imagelink/lifebetterinflipflops.jpg\" > </a>"
    
    page = Page.find_by_name( 'imagelink2')
    assert_equal page.content, "IMAGELINK2 <%= imagelink lifebetterinflipflops.jpg, width = 200 %>"
    assert_equal page.display, "IMAGELINK2 <a href=\"/storage/imagelink2/lifebetterinflipflops.jpg\"> <img src=\"/storage/imagelink2/lifebetterinflipflops.jpg\"  width = 200> </a>"
    
  end
    
   
  test 'pin' do
    page = Page.find_by_name( 'pin' )
    assert_equal page.display, "PIN <div class=\"pindiv panel panel-default\"><div class=\"pinmargin panel-body \">  <h3> 4</h3> (!&) <p><a href= \"https://pic.g?au m/11 4?a t6AE#slc=\"https://  </div></div>"
  end

  test 'questions' do
    page = Page.find_by_name( 'questions' )
    assert_equal page.display, "QUESTIONS <p> [\"green is=\", \"blue is=\"]?</p><br>"
  end
  
  test 'basepage' do
    assert_equal Page.basepage( nil ), ''
    assert_equal Page.basepage( 'something'), 'something'
    assert_equal Page.basepage( 'some_thing'), 'some_thing'
    assert_equal Page.basepage( 'some_header'), 'some'
    assert_equal Page.basepage( 'some_menu'), 'some'  
    assert_equal Page.basepage( 'some_footer'), 'some' 
    assert_equal Page.basepage( 'some_left'), 'some' 
    assert_equal Page.basepage( 'some_right'), 'some'   
    assert_equal Page.basepage( 'header'), 'header'
    assert_equal Page.basepage( 'menu'), 'menu'  
    assert_equal Page.basepage( 'footer'), 'footer' 
    assert_equal Page.basepage( 'left'), 'left' 
    assert_equal Page.basepage( 'right'), 'right'              
  end
  
  test 'cache a page and delete it' do
    
    if Rails.configuration.page_caching
      cachedir = File.join( Rails.root , 'public', 'cache' )    
      if !Dir.exists? cachedir
        Dir.mkdir cachedir
      end
      assert Dir.exists? cachedir
    
      strange = 'asdjk_lwqfij_orieg'
      page = Page.new( name: strange, user_id: @wido.id )
      page.save!
    
      # cache a page... first check it doesn't exist
      path = File.join( Rails.root , 'public/cache/testsite', strange ) + '.html'    
      assert_not File.exists?(path), "cached file is present in /public/cache/testsite"
      page.cache( 'this is a cached test page' )
      assert File.exists?(path)
    
      # now delete cached files
      Page.uncache_all
      assert_not File.exists?(path)
    end
    
  end

end

