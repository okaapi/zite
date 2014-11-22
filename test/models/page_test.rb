require 'test_helper'

class PageTest < ActiveSupport::TestCase
  
  setup do
    @wido = User.find_by_username('wido_admin')
    # need to change <#= #> to <%= %>
    pages = Page.all
    pages.each do |page|
      page.content = page.content.gsub(/<#=/,'<%=').gsub(/#>/,'%>') if page.content
      page.user_id = @wido.id
      page.save!  
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
    one = pages( :one  )
    # make sure it's the most recent one...
    one.id_will_change!
    sleep( 1 )
    one.save!    
    #
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
    
    Page.create( name: 'time', user_id: @wido.id, content: 'oldest')
    Page.create( name: 'time_left', user_id: @wido.id, content: 'oldest')    
    sleep(1)
    Page.create( name: 'time', user_id: @wido.id,  content: 'old')
    Page.create( name: 'time_left', user_id: @wido.id,   content: 'old')    
    sleep(1)    
    Page.create( name: 'time', user_id: @wido.id,  content: 'latest')
    Page.create( name: 'time_left', user_id: @wido.id,   content: 'latest')    
   

    header, menu, left, center, right, footer = Page.get_layout( 'time' )    
    assert_equal center.content, 'latest'
    assert_equal left.content, 'latest'
        
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
    assert_equal page.display, "PIN <div class=\"pindiv\">  <h3> 4</h3> (!&) <p><a href= \"https://pic.g?au m/11 4?a t6AE#slc=\"https://  </div>"
  end

  test 'questions' do
    page = Page.find_by_name( 'questions' )
    assert_equal page.display, "QUESTIONS <p> green is=?</p><br><p> blue is=?</p><br>"
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
  
end

