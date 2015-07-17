require 'test_helper'

class SeiteUserStoriesTest < ActionDispatch::IntegrationTest
  
  setup do
    Rails.configuration.site = 'testsite'
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
    @not_java = ! Rails.configuration.use_javascript
    # not sure why request has to be called first, but it won't work without
    request
    open_session.host! "testsite"
  end

  test "different site" do

    open_session.host! "othersite"
    get_via_redirect "/"    
    assert_response :success
    assert_select '.center', ''      
    
    get_via_redirect "/talks"
    assert_response :success
    assert_select '.center', 'Talks On Othersite'  
        
  end
  
  test "viewing a page not logged in" do
     
    # this for caching
    path = File.join( Rails.root , 'public', 'index' ) + '.html'    
    File.delete( path ) if File.exists? path

    get_via_redirect "/"
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
    
    get_via_redirect "/talks"
    assert_response :success
    assert_select '.center', 'protected content...'
    if Rails.configuration.page_caching
      path = File.join( Rails.root , 'public', 'talks' ) + '.html'    
      assert File.exists? path
      File.delete( path )
    end
    
  end

  #
  test "viewing a page logged in" do
  
    # for caching
    path = File.join( Rails.root , 'public', 'index' ) + '.html'   
    if Rails.configuration.page_caching 
      File.open(path, "w") do |f|
        f.write( "this index.html should get deleted when logging in" )
      end
    end
    
    # enters correct password and gets logged in and session is created
    if @not_java
      post "/_prove_it", claim: "arnaud", password: "secret"
      assert_redirected_to root_path
    else
      xhr :post, "/_prove_it", claim: "arnaud", password: "secret"
      assert_response :success
    end
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
     
  end
  
  #
  test "viewing a page logged in as admin" do
  
    # enters correct password and gets logged in and session is created
    if @not_java
      post "/_prove_it", claim: "wido_admin", password: "secret"
      assert_redirected_to root_path
    else
      xhr :post, "/_prove_it", claim: "wido_admin", password: "secret"
      assert_response :success
    end
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
  
end