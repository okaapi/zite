require 'test_helper'

class SeiteUserStoriesTest < ActionDispatch::IntegrationTest
  
  setup do

    ZiteActiveRecord.site( 'testsite45A67' )
    @user_arnaud = users(:arnaud)
    @wido = users(:admin)
    # need to change <#= #> to <%= %>
    pages = Page.all
    pages.each do |page|
      if page.content and /<#=/ =~ page.content
        page.content = page.content.gsub(/<#=/,'<%=').gsub(/#>/,'%>')
        page.save!
      end  
    end
    # not sure why request has to be called first, but it won't work without
    request
    open_session.host! "testhost45A67"
	
    if (Rails.configuration.respond_to? 'page_caching') and Rails.configuration.page_caching            
      delete_cache_directories_with_content
    end 
	
  end


  test "different site" do


    open_session.host! "othersite45A67"
    get "/"    
    assert_response :success
    assert_select '.center', ''      

    # should get the right "talks" page (exists in both othersite and testsite)
    get "/talks"
    assert_response :success
    assert_select '.center', 'Talks On Othersite'  

    # should NOT get "talks_books" page (exists only in testsite)
    get "/talks_books"
    assert_response :success
    assert_select '.center', ''  
   
    if Rails.configuration.page_caching
      delete_cache_directories_with_content
    end
             
  end

  test "viewing a page not logged in from testhost" do
     
    # this for caching
    if Rails.configuration.page_caching
      cachedir = SiteMap.by_external( 'testhost45A67' ) 
      path = File.join( Rails.root , 'public/cache', cachedir, 'index' ) + '.html'    
      File.delete( path ) if File.exists? path
    end

    get "/"
    assert_response :success
    assert_select '.header', 'INDEX HEADER'
    assert_select '.menu', 'INDEX MENU'      
    assert_select '.left', 'INDEX LEFT' 
    assert_select '.center', 'Index Page'
    assert_select '.right', 'INDEX RIGHT' 
    assert_select '.footer', 'INDEX FOOTER'
    
    if Rails.configuration.page_caching
      assert File.exists? path
      File.delete( path )
    end
    
    get "/talks"
    assert_response :success
    assert_select '.center', 'protected content...'
    
    if Rails.configuration.page_caching
      delete_cache_directories_with_content
    end
    
  end

  test "viewing a page not logged in from othersite (no site_map)" do
     
    request
    open_session.host! "othersite45A67"
    ZiteActiveRecord.site( "othersite45A67" )
    assert_equal ZiteActiveRecord.site?, "othersite45A67"
    
    # this for caching
    if Rails.configuration.page_caching
      path = File.join( Rails.root , 'public/cache/othersite45A67', 'talks' ) + '.html'    
      File.delete( path ) if File.exists? path
    end

    get "/talks"
    assert_response :success
        
    if Rails.configuration.page_caching
      assert (File.exists? path), message: "othersite45A67 index not cached...."
      File.delete( path )
    end
    
    if Rails.configuration.page_caching
      delete_cache_directories_with_content
    end
    
  end  

  test "viewing a page logged in" do
  
    # for caching 
    if Rails.configuration.page_caching 
      make_cache_directories( 'testhost45A67' )     
      path = File.join( Rails.root , 'public/cache/testhost45A67', 'index' ) + '.html'        
      File.open(path, "w") do |f|
        f.write( "this index.html should get deleted when logging in" )
      end
    end
    
    # enters correct password and gets logged in and session is created
      post "/_prove_it", params: { claim: "arnaud", kennwort: "secret" }
      assert_redirected_to root_path
    assert_equal flash[:notice], 'arnaud logged in'

    get "/"
    assert_response :success
    assert_select '.header', 'INDEX HEADER'
    assert_select '.menu', 'INDEX MENU'      
    assert_select '.left', 'INDEX LEFT' 
    assert_select '.center', 'Index Page'
    assert_select '.right', 'INDEX RIGHT' 
    assert_select '.footer', 'INDEX FOOTER'
    # for caching    
    if Rails.configuration.page_caching
      assert_not File.exists? path
    end 
    
    get "/talks"
    assert_response :success
    assert_select '.center', 'protected content...'
    
    if Rails.configuration.page_caching
      delete_cache_directories_with_content
    end
     
  end

  test "viewing a page logged in as admin" do
  
    # enters correct password and gets logged in and session is created

      post "/_prove_it", params: { claim: "wido_admin", kennwort: "secret" }
      assert_redirected_to root_path

    assert_equal flash[:notice], 'wido_admin logged in'
    
    get "/"
    assert_response :success
    assert_select '.header', 'INDEX HEADER'
    assert_select '.menu', 'INDEX MENU'      
    assert_select '.left', 'INDEX LEFT' 
    assert_select '.center', 'Index Page'
    assert_select '.right', 'INDEX RIGHT' 
    assert_select '.footer', 'INDEX FOOTER'
    
    get "/talks"
    assert_response :success
	assert_select '.center', 'Talks'
  end

  test "redirect to original page after login" do
  
	get "/_who_are_u", headers: { 'HTTP_REFERER' => 'http://testhost45A67/talks'  }
	assert_response :success	
	assert_equal @controller.session[:login_from], 'talks'	
	
    # enters correct password and gets logged in and session is created

      post "/_prove_it", params: { claim: "arnaud", kennwort: "secret" }
      assert_redirected_to root_path + 'talks'

    assert_equal flash[:notice], 'arnaud logged in'
	assert_nil @controller.session[:login_from]
  
  end

end