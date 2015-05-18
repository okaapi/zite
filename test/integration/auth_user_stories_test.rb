require 'test_helper'

class AuthUserStoriesTest < ActionDispatch::IntegrationTest
  
  setup do
    @user_arnaud = users(:arnaud)                    
    @user_francois = users(:francois)    
    @not_java = ! Rails.configuration.use_javascript
  end
  
 
  #
  #   these tests are all set up to NOT examine internals of the app (session 
  #   object, models etc...  only testing flash, notice, and HTML
  #
  test "root path" do
    assert_equal root_path, '/'

  end
  
  #
  #  user logs in and out with correct credentials
  #  (error handling is tested in the controller)
  #
  test "logging in and out" do
  
    # user comes to the website and sees the "login" link
    get_via_redirect "/"
    assert_response :success
    assert_select '#authentication_launchpad a', 'login'

    # clicks the login link and gets username entry field
    if @not_java
      get "/_who_are_u"
      assert_response :success
      assert_select '.control-label', /username\/email/ 
    else
      xhr :get, "/_who_are_u"
      assert_response :success
      assert_select_jquery :html, '#authentication_dialogue_js' do
        assert_select '.control-label', /username\/email/ 
      end
    end
        
    # enters username and gets password entry field with username legend
    if @not_java
      post "/_prove_it", claim: "arnaud"
      assert_response :success
      assert_select '.alert-info', /arnaud/
      assert_select '.control-label', /password/            
    else
      xhr :post, "/_prove_it", claim: "arnaud"
      assert_response :success       
      assert_select_jquery :html, '#authentication_dialogue_js' do    
        assert_select '.alert-info', /arnaud/
        assert_select '.control-label', /password/
      end      
    end
      
    # enters correct password and gets logged in and session is created
    if @not_java  
      post "/_prove_it", claim: "arnaud", password: "secret"
    else
      xhr :post, "/_prove_it", claim: "arnaud", password: "secret"
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
    get_via_redirect "/"
    assert_response :success
    assert_select '#authentication_launchpad', /login/ 
                 
  end
    
  #
  #  user registers, gets an email, and is also logged in
  #  (error handling is tested in the controller)
  #  
  test "registering and getting logged in" do
  
    # user clicks "registration" link
    if @not_java
      post "/_about_urself"
      assert_response :success
      assert_select '.control-label', /username/
      assert_select '.control-label', /email/        
    else  
      xhr :post, "/_about_urself"
      assert_response :success
      assert_select_jquery :html, '#authentication_dialogue_js' do
        assert_select '.control-label', /username/
        assert_select '.control-label', /email/           
      end
    end
    
    # user enters proper username / email combo
    if @not_java
      post "/_about_urself", username: "jim", email: "jim@gmail.com"
    else  
      xhr :post, "/_about_urself", username: "jim", email: "jim@gmail.com"       
    end
    assert_root_path_redirect    
    assert_equal flash[:notice], 
      "you are logged in, we sent an activation email for the next time!" 
    
    # has email been sent?
    assert_equal Rails.configuration.action_mailer.delivery_method, :test
    assert_equal ActionMailer::Base.deliveries[0].subject, "Okaapi registration confirmation"
    assert_equal ActionMailer::Base.deliveries[0].to[0], "jim@gmail.com"
    
    # refreshes and confirms that user is shown as logged in
    get "/"
    assert_response :success
    assert_select '#authentication_launchpad', /jim/       
  end
  
  #
  #  user clicks on the link in the email sets password, and gets logged in
  #  (error handling is tested in the controller)
  #  
  test "setting password" do
    
    # user clicks on the link
    get "/_from_mail", user_token: 'francois_token'       
    assert_redirected_to root_path
    
    # refreshes and still gets the correct user displayed
    get_via_redirect "/"
    assert_response :success
    assert_select '.alert-info', /francois/
    assert_select '.control-label', /password/     
    
    # sets the password and gets logged in
    if @not_java
      post "/_ur_secrets", user_id: @user_francois.id, password: 'secret', password_confirmation: 'secret' 
    else
      xhr :post, "/_ur_secrets", user_id: @user_francois.id, 
                        password: 'secret', password_confirmation: 'secret'   
    end
    assert_root_path_redirect
    assert_equal flash[:notice], "password set!"         
    
    # user refreshes and username is displayed
    get "/"
    assert_response :success
    assert_select '#authentication_launchpad', /francois/
      
  end



  
  private
     
    def root_path
      '/'
    end
    def assert_root_path_redirect
      if @not_java
        assert_redirected_to root_path
        assert @response.body =~ /redirected/  
      else
        assert_response :success
        assert @response.body =~ /window.location/  
      end
    end
    
end

