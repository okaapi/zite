require 'test_helper'

class AuthUserStoriesTest < ActionDispatch::IntegrationTest
  
  setup do
    # need this so the users fixtures can be loaded
    ZiteActiveRecord.site( 'testsite45A67' )
    @user_arnaud = users(:arnaud)                    
    @user_francois = users(:francois)    
    @not_java = true
    # not sure why request has to be called first, but it won't work without
    request
    open_session.host! "testhost45A67"
    if (Rails.configuration.respond_to? 'page_caching') and Rails.configuration.page_caching            
      delete_cache_directories_with_content
    end 
  end

  #
  #   these tests are all set up to NOT examine internals of the app (session 
  #   object, models etc...  only testing flash, notice, and HTML)
  #
  test "root path" do
    assert_equal root_path, '/'
  end

  #
  #  user logs in and out with correct credentials
  #  (error handling is tested in the controller)
  #
  test "logging in and out" do
    
    [true,false].each do |java|
          
        Rails.configuration.use_javascript = java
        @not_java = ! Rails.configuration.use_javascript
                
	    # user comes to the website and sees the "login" link
	    get "/"
	    assert_response :success
	    assert_select '#authentication_launchpad a', 'login'
	
	    # clicks the login link and gets username entry field
	    if ! Rails.configuration.use_javascript
	      get "/_who_are_u"
	      assert_response :success
	      assert_select '.control-label', /username\/email/ 
	    else
	      get "/_who_are_u", xhr:true
	      assert_response :success
	      assert_select_jquery :html, '#authentication_dialogue_js' do
	        assert_select '.control-label', /username\/email/ 
	      end
	    end
	
	    # enters username and gets password entry field with username legend
	    if ! Rails.configuration.use_javascript
	      post "/_prove_it", params: { claim: "arnaud" }
	      assert_response :success
	      assert_select '.alert-info', /arnaud/
	      assert_select '.control-label', /password/            
	    else
	      post "/_prove_it", xhr: true, params: { claim: "arnaud" }
	      assert_response :success       
	      assert_select_jquery :html, '#authentication_dialogue_js' do    
	        assert_select '.alert-info', /arnaud/
	        assert_select '.control-label', /password/
	      end      
	    end
	      
	    # enters correct password and gets logged in and session is created
	    if ! Rails.configuration.use_javascript  
	      post "/_prove_it", params: { claim: "arnaud", kennwort: "secret" }
	    else
	      post "/_prove_it", xhr: true, params: { claim: "arnaud", kennwort: "secret" }
	    end
	    assert_root_path_redirect    
	    assert_equal flash[:notice], 'arnaud logged in'
	          
	    
	    # user refreshes and username is displayed
	    get "/"
	    assert_response :success
	    assert_select '#authentication_launchpad', /arnaud/
	    
	    # logs out
	    get "/_see_u"
	    assert_redirected_to root_path
	      
	    # refreshes and confirms that user is not shown as logged in
	    get "/"
	    assert_response :success
	    assert_select '#authentication_launchpad', /login/ 
           
    end
          
  end
  
  #
  #  user registers, gets an email, and is also logged in
  #  (error handling is tested in the controller)
  #  
  test "registering and getting logged in" do
  
    [true, false].each do |java|
                 
        #because we run this twice...
        jim = User.find_by_username('jim')
        jim.destroy if jim
        ActionMailer::Base.deliveries = []        

        Rails.configuration.use_javascript = java
        @not_java = ! Rails.configuration.use_javascript
          
	    # user clicks "registration" link
	    if ! Rails.configuration.use_javascript
	      post "/_about_urself"
	      assert_response :success
	      assert_select '.control-label', /username/
	      assert_select '.control-label', /email/        
	    else  
	      post "/_about_urself", xhr: true
	      assert_response :success
	      assert_select_jquery :html, '#authentication_dialogue_js' do
	        assert_select '.control-label', /username/
	        assert_select '.control-label', /email/           
	      end
	    end
	
	    # user enters proper username / email combo
	    if ! Rails.configuration.use_javascript
	      post "/_about_urself", params: { username: "jim", email: "jim@gmail.com" }
	    else  
	      post "/_about_urself", xhr: true, params: { username: "jim", email: "jim@gmail.com" }
	    end
	    assert_equal flash[:notice], 
	        "Please check your email jim@gmail.com (including your SPAM folder) for an email to verify it's you and set your password!"
	    assert_root_path_redirect  
	    
	    # has email been sent?
	    assert_equal Rails.configuration.action_mailer.delivery_method, :test
	    assert_equal ActionMailer::Base.deliveries[0].subject, "Registration information for testhost45A67"
	    assert_equal ActionMailer::Base.deliveries[0].to[0], "jim@gmail.com"
	    
	    # refreshes and confirms that user is shown as logged in
	    get "/"
	    assert_response :success
	    assert_select '#authentication_launchpad', /login/    
    end
  end

  #
  #  user clicks on the link in the email sets password, and gets logged in
  #  (error handling is tested in the controller)
  #  
  test "setting password" do
    
    [true,false].each do |java|
           
        User.find_by_username( 'francois' ).update_attribute( :token, 'francois_token' )     
        
        Rails.configuration.use_javascript = java
        @not_java = ! Rails.configuration.use_javascript
        
	    # user clicks on the link
	    get "/_from_mail", params: { user_token: 'francois_token' }
	    assert_redirected_to root_path
	    	
	    # refreshes and still gets the correct user displayed
	    get "/"
	    assert_response :success
	    assert_select '.control-label', /password/    	    
	    assert_select '.alert-info', /francois/
	    
	    # sets the password and gets logged in
	    if ! Rails.configuration.use_javascript
	      post "/_ur_secrets", params: { user_id: @user_francois.id, 
	                               kennwort: 'secret', password_confirmation: 'secret' } 
	    else
          post "/_ur_secrets", xhr: true, params: { user_id: @user_francois.id, 
	                               kennwort: 'secret', confirmation: 'secret' }  
	    end
	    
	    assert_root_path_redirect
	    assert_equal flash[:notice], "password set, you are logged in!"         
	
	    # user refreshes and username is displayed
	    get "/"
	    assert_response :success
	    assert_select '#authentication_launchpad', /francois/
	    
	end
  end
  
  #
  #  user logs in and out from one site, then another
  #
  test "logging in and out from two sites" do
    
    Rails.configuration.use_javascript = false
	ZiteActiveRecord.site( 'otherhost' )
	u = User.create( username: 'benoit', email: 'benoit@gmail.com', active: 'confirmed',
	                 password: 'secret', password_confirmation: 'secret' )
    u.save!   	
	
	ZiteActiveRecord.site( 'testsite45A67' )
    request
    open_session.host! "testhost45A67"
	
    get "/_who_are_u"
    post "/_prove_it", params: { claim: "arnaud" }
    post "/_prove_it", params: { claim: "arnaud", kennwort: "secret" }
	assert_equal flash[:notice], 'arnaud logged in'  
    get "/"
    assert_response :success
    assert_select '#authentication_launchpad', /arnaud/
	
	ZiteActiveRecord.site( 'otherhost' )
    request
    open_session.host! "otherhost"
	
    get "/_who_are_u"
    post "/_prove_it", params: { claim: "benoit" }
    post "/_prove_it", params: { claim: "benoit", kennwort: "secret" }
	assert_not_nil assigns(:current_user)
	assert_equal flash[:notice], 'benoit logged in'  
    get "/"
    assert_response :success
    assert_select '#authentication_launchpad', /benoit/	
          
	ZiteActiveRecord.site( 'testsite45A67' )
    request
    open_session.host! "testhost45A67"
    get "/"
    assert_response :success
    assert_select '#authentication_launchpad', /arnaud/	
	
  end

  private
     
    def root_path
      '/'
    end
    def assert_root_path_redirect
      if ! Rails.configuration.use_javascript
        assert_redirected_to root_path
        assert @response.body =~ /redirected/  
      else
        assert_response :success
        assert @response.body =~ /window.location/  
      end
    end

end

