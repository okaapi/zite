require 'test_helper'

class AuthUserStoriesTest < ActionDispatch::IntegrationTest
  
  setup do
    @user_arnaud = Auth::User.new( username: 'arnaud', email: 'arnaud@gmail.com', active: 'confirmed',
                                 password: 'secret', password_confirmation: 'secret')
    @user_arnaud.save!                                 
    @user_francois = Auth::User.new( username: 'francois', email: 'francois@gmail.com',
                                 password: 'secret', password_confirmation: 'secret',
                                 token: 'francois_token' )
    @user_francois.save!      
    @not_java = ! Rails.configuration.use_javascript
  end
  
  #
  #   these tests are all set up to NOT examine internals of the app (session 
  #   object, models etc...  only testing flash, notice, and HTML
  #
  test "root path" do
    assert_equal root_path, '/'
    puts "[ javascript is " + ( @not_java ? "off ]" : "on ]" ) 
  end
  
  #
  #  user logs in and out with correct credentials
  #  (error handling is tested in the controller)
  #
  test "logging in and out" do
  
    # user comes to the website and sees the "login" link
    get "/"
    assert_response :success
    assert_select '#authentication_launchpad a', 'login'

    # clicks the login link and gets username entry field
    if @not_java
      get "/who_are_u"
      assert_response :success
      assert_select '.authenticate fieldset div label', /username\/email/ 
    else
      xhr :get, "/who_are_u"
      assert_response :success
      assert_select_jquery :html, '#authentication_dialogue' do
        assert_select 'fieldset div label', /username\/email/ 
      end
    end
        
    # enters username and gets password entry field with username legend
    if @not_java
      post "/prove_it", claim: "arnaud"
      assert_response :success
      assert_select '.authenticate fieldset legend', /arnaud/
      assert_select '.authenticate fieldset div label', /password/            
    else
      xhr :post, "/prove_it", claim: "arnaud"
      assert_response :success       
      assert_select_jquery :html, '#authentication_dialogue' do    
        assert_select '.authenticate fieldset legend', /arnaud/
        assert_select '.authenticate fieldset div label', /password/
      end      
    end
      
    # enters correct password and gets logged in and session is created
    if @not_java  
      post "/prove_it", claim: "arnaud", password: "secret"
    else
      xhr :post, "/prove_it", claim: "arnaud", password: "secret"
    end
    assert_root_path_redirect    
    assert_equal flash[:notice], 'arnaud logged in'
      
    # user refreshes and username is displayed
    get "/"
    assert_response :success
    assert_select '#authentication_launchpad', /arnaud/
    
    # logs out
    get "/see_u"
    assert_redirected_to root_path
      
    # refreshes and confirms that user is not shown as logged in
    get "/"
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
      post "/about_urself"
      assert_response :success
      assert_select '.authenticate fieldset div label', /username/
      assert_select '.authenticate fieldset div label', /email/        
    else  
      xhr :post, "/about_urself"
      assert_response :success
      assert_select_jquery :html, '#authentication_dialogue' do
        assert_select '.authenticate fieldset div label', /username/
        assert_select '.authenticate fieldset div label', /email/           
      end
    end
    
    # user enters proper username / email combo
    if @not_java
      post "/about_urself", username: "jim", email: "jim@gmail.com"
    else  
      xhr :post, "/about_urself", username: "jim", email: "jim@gmail.com"       
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
    get "/from_mail", user_token: 'francois_token'       
    assert_redirected_to root_path
    
    # refreshes and still gets the correct user displayed
    get "/"
    assert_response :success
    assert_select '.authenticate fieldset legend', /francois/
    assert_select '.authenticate fieldset div label', /password/     
    
    # sets the password and gets logged in
    if @not_java
      post "/ur_secrets", user_id: @user_francois.id, password: 'secret', password_confirmation: 'secret' 
    else
      xhr :post, "/ur_secrets", user_id: @user_francois.id, 
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

