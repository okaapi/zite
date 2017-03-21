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
        request.host = 'testhost45A67'	
	    get :index        
	    assert_not_equal flash[:alert], 'name mismatch testsite45A67 testhost45A67'     
	  end	
  

	  test "should get index" do
	    get :index
	    assert_response :success
	    assert_not_nil assigns(:site_maps)
	  end
	    	  	
	  test "no sitemap in db" do
	    request.host = 'testsite45A67'	
        SiteMap.delete_all
	    get :index
	    assert_response :success   
	  end
	  	  
	  test "wrong sitemap" do
	    request.host = 'wrongtesthost'
	    get :index
        assert_not_equal flash[:alert], 'name mismatch testsite45A67 wrongtesthost' 	    
	  end
  	
	  test "should get new" do
	    get :new
	    assert_response :success
	  end
	
	  test "should create site_map" do
	    assert_equal SiteMap.count, 1
	    assert_difference('SiteMap.count') do
	      post :create, params: { site_map: { external: 'ext', internal: 'int' } }
	    end
	    assert_redirected_to site_map_path(assigns(:site_map))
	  end

	  test "should create site_map error" do
	    assert_equal SiteMap.count, 1
	    assert_difference('SiteMap.count', 0) do
	      post :create, params: { site_map: { external: @site_map.external , internal: 'int' } }
	    end
        assert_equal assigns(:site_map).errors.count, 1    	    
	    assert_response :success
	  end	  
	  	
	  test "should show site_map" do
	    get :show, params: { id: @site_map }
	    assert_response :success
	  end

	  test "should get edit" do
	    get :edit, params: { id: @site_map }
	    assert_response :success
	  end

	  test "should update site_map" do
	    patch :update, params: { id: @site_map, 
		  site_map: { aux: @site_map.aux, external: @site_map.external, internal: @site_map.internal } }
	    assert_redirected_to site_map_path(assigns(:site_map))
	  end
	  
	  test "should update site_map error" do
	    sm = SiteMap.new( external: "ext1", internal: "int1" )
	    sm.save
	    patch :update, params: { id: @site_map, 
		  site_map: { aux: @site_map.aux, external: "ext1", internal: @site_map.internal } }
        assert_equal assigns(:site_map).errors.count, 1    	    
	    assert_response :success
	  end	  
	
	  test "should destroy site_map" do
	    assert_difference('SiteMap.count', -1) do
	      delete :destroy, params: { id: @site_map }
	    end
	
	    assert_redirected_to site_maps_path
	  end

	end

end
