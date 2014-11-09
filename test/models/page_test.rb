require 'test_helper'

class PageTest < ActiveSupport::TestCase
  
  setup do
    @wido = Auth::User.find_by_username('wido_admin')
    # need to change <#= #> to <%= %>
    pages = Page.all
    pages.each do |page|
      page.content = page.content.gsub(/<#=/,'<%=').gsub(/#>/,'%>')
      page.user_id = @wido.id
      page.save!  
    end
  end
  
=begin 
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
    users = Auth::User.all
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
    users = Auth::User.all
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
    assert_equal page.content, "INCLUDE <%= include home %>"
    assert_equal page.display, "INCLUDE <h1> Home Page </h1>"
  end
  
  test 'test pagelink' do
     
    page = Page.find_by_name( 'pagelink')
    assert_equal page.content, "PAGELINK <%= pagelink home %>"
    assert_equal page.display, "PAGELINK <a href=\"/home\" class=\"pagelink\">home</a>" 
    
    page = Page.find_by_name( 'pagelink2')
    assert_equal page.content, "PAGELINK2 <%= pagelink home, link to home %>"
    assert_equal page.display, "PAGELINK2 <a href=\"/home\" class=\"pagelink\"> link to home</a>"
    
    page = Page.find_by_name( 'pagelink3')
    assert_equal page.content, 
         "PAGELINK3 <%= pagelink home %> SOME TEXT <%= pagelink home, link to home %>"
    assert_equal page.display, "PAGELINK3 <a href=\"/home\" class=\"pagelink\">home</a> SOME TEXT <a href=\"/home\" class=\"pagelink\"> link to home</a>"    
        
    page = Page.find_by_name( 'adminlink')
    assert_equal page.content, "ADMINLINK <%= adminlink admin %>"
    assert_equal page.display, "ADMINLINK "   
        
    page = Page.find_by_name( 'adminlink')
    assert_equal page.content, "ADMINLINK <%= adminlink admin %>"
    assert_equal page.display('admin'), "ADMINLINK <a href=\"/admin\" class=\"adminlink\">admin</a>"   
    
     
        
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

    header, menu, left, center, right, footer = Page.get_layout( 'home' )
    assert_equal header.name, 'home_header'
    assert_equal menu.name, 'home_menu'
    assert_equal left.name, 'home_left'
    assert_equal center.name, 'home'
    assert_equal right.name, 'home_right'
    assert_equal footer.name, 'home_footer'
    
    header, menu, left, center, right, footer = Page.get_layout( 'presentations' )
    assert_not header
    assert_not menu
    assert_not left
    assert_not right
    assert_equal footer.name, 'footer'      

  end
  
  test 'css' do
    assert_equal Page.get_css, "{ color: red } "
  end
  
  test 'more panels' do
    assert_equal Page.get_panel( 'home', 'left').name, "home_left"
    assert_not Page.get_panel( 'presentations', 'left')
    assert_equal Page.get_panel_or_default( 'home', 'left').name, "home_left"
    assert_equal Page.get_panel_or_default( 'presentations', 'menu').name, "menu"
  end
  
  test 'display chronological' do
    
    Page.create( name: 'time', user_id: @wido.id, content: 'oldest')
    Page.create( name: 'time', user_id: @wido.id,  content: 'old')
    Page.create( name: 'time', user_id: @wido.id,  content: 'latest')
    Page.create( name: 'time_left', user_id: @wido.id, content: 'oldest')
    Page.create( name: 'time_left', user_id: @wido.id,   content: 'old')
    Page.create( name: 'time_left', user_id: @wido.id,   content: 'latest')
    header, menu, left, center, right, footer = Page.get_layout( 'time' )
    assert_equal center.content, 'latest'
    assert_equal left.content, 'latest'
        
  end
  
  test 'imagelink' do
    page = Page.find_by_name( 'imagelink')
    assert_equal page.content, "IMAGELINK <%= imagelink lifebetterinflipflops.jpg %>"
    assert_equal page.display, "IMAGELINK <a href=\"/storage/imagelink/lifebetterinflipflops.jpg\"> <img src=\"/storage/imagelink/lifebetterinflipflops.jpg\"> </a>"
    
    page = Page.find_by_name( 'imagelink2')
    assert_equal page.content, "IMAGELINK2 <%= imagelink lifebetterinflipflops.jpg, width = 200 %>"
    assert_equal page.display, "IMAGELINK2 <a href=\"/storage/imagelink2/lifebetterinflipflops.jpg\"> <img src=\"/storage/imagelink2/lifebetterinflipflops.jpg\" width = 200> </a>"
    
  end
  
=end  
  test 'pin' do
    page = Page.find_by_name( 'pin' )
    page.content = '<%= pin ontent.com/-Ty8ugO_MEEc/U_qm6SbvR5I/AAAAAAAAE3Q/fYvN9A8iDqc/s128/IMG_1402.JPG" alt="" /></a></p> %>'
    assert_equal page.display, 'bla'
  end
  
end

