require 'test_helper'

module Admin

	class PagesControllerTest < ActionController::TestCase
	  setup do
	    Rails.configuration.site = 'testsite'  
	    @page = pages(:one)
	    @wido = users(:wido)
	    admin_login_4_test    
	    request.host = 'testsite'	    
	  end
	
	  test "should get index" do
	    get :index
	    assert_response :success
	    assert_not_nil assigns(:pages)
	  end
	
	  test "should get index by name" do
	    get :index, by_name: 'true'
	    assert_response :success
	    assert_not_nil assigns(:pages)
	  end
	  	
	  test "should get new" do
	    get :new
	    assert_response :success
	  end
	
	  test "should create page" do
	    assert_difference('Page.count') do
	      post :create, page: { content: @page.content, editability: @page.editability, 
	        lock: @page.lock, menu: @page.menu, 
	        user_id: @wido.id, visibility: @page.visibility }
	    end
	
	    assert_redirected_to page_path(assigns(:page))
	  end
	
	  test "should not create page without user ID" do
	    assert_no_difference('Page.count') do
	      post :create, page: { content: @page.content, 
	        editability: @page.editability, id: 0,
	        lock: @page.lock, menu: @page.menu, 
	        visibility: @page.visibility }
	    end

	  end
	  	
	  test "should show page" do
	    get :show, id: @page
	    assert_response :success
	  end
	
	  test "should get edit" do
	    get :edit, id: @page
	    assert_response :success
	  end
	
	  test "should update page" do
	    patch :update, id: @page, page: { content: @page.content, editability: @page.editability, 
	      lock: @page.lock, menu: @page.menu, user_id: @wido.id, visibility: @page.visibility }
	    assert_redirected_to page_path(assigns(:page))
	  end
	
	  test "should destroy page" do
	    assert_difference('Page.count', -1) do
	      delete :destroy, id: @page
	    end
	
	    assert_redirected_to pages_path
	  end
	end

end