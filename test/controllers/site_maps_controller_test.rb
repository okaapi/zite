require 'test_helper'

module Admin

    class SiteMapsControllerTest < ActionController::TestCase
	  setup do
            ZiteActiveRecord.site( 'testsite45A67' )
	    @site_map = site_maps(:one)
	    @wido = users(:wido)
	    admin_login_4_test    
	    request.host = 'testhost45A67'	  
	  end
	  
	  test "wrong sitemap with no sitemap in db" do
            SiteMap.delete_all
	    get :index
	    assert_equal flash[:alert], nil #'name mismatch testsite45A67 testhost45A67'     
	  end	
	  
	  test "wrong sitemap" do
	    request.host = 'wrongtesthost'
	    get :index
            assert_equal flash[:alert], nil #'name mismatch testsite45A67 wrongtesthost' 	    
	  end

	  test "no sitemap in db" do
	    request.host = 'testsite45A67'	
        SiteMap.delete_all
	    get :index
	    assert_response :success   
	  end		  

	  test "should get index" do
	    get :index
	    assert_response :success
	    assert_not_nil assigns(:site_maps)
	  end
	
	  test "should get new" do
	    get :new
	    assert_response :success
	  end
	
	  test "should create site_map" do
	    assert_equal SiteMap.count, 1
	    assert_difference('SiteMap.count') do
	      post :create, site_map: { external: 'ext', internal: 'int' }
	    end
	    assert_redirected_to site_map_path(assigns(:site_map))
	  end
	  
	  test "should create site_map error" do
	    assert_equal SiteMap.count, 1
	    assert_difference('SiteMap.count', 0) do
	      post :create, site_map: { external: @site_map.external , internal: 'int' }
	    end
	    assert_response :success
	  end	  
	
	  test "should show site_map" do
	    get :show, id: @site_map
	    assert_response :success
	  end
	
	  test "should get edit" do
	    get :edit, id: @site_map
	    assert_response :success
	  end
	
	  test "should update site_map" do
	    patch :update, id: @site_map, site_map: { aux: @site_map.aux, external: @site_map.external, internal: @site_map.internal }
	    assert_redirected_to site_map_path(assigns(:site_map))
	  end
	
	  test "should destroy site_map" do
	    assert_difference('SiteMap.count', -1) do
	      delete :destroy, id: @site_map
	    end
	
	    assert_redirected_to site_maps_path
	  end
  
	end

end
