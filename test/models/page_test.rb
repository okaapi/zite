require 'test_helper'

class PageTest < ActiveSupport::TestCase
  
  setup do
    @wido = Auth::User.find_by_username('wido_admin')
    Page.delete_all
    Page.visibilities.each do |v|
      Page.editabilities.each do |p|
        Page.create( user_id: @wido.id, editability: p, visibility: v  )
      end
    end
  end
  
  test 'visibilities and editabilities' do
    assert_equal Page.visibilities, ["any", "user", "editor", "self", "admin"]
    assert_equal Page.editabilities, ['admin', 'self', 'editor']
  end
  
  test 'test visibility for different users' do
    
    pages = Page.all
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
    
    pages = Page.all
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
  
end

