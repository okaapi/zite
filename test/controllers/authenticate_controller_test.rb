require 'test_helper'

class AuthenticateControllerTest < ActionController::TestCase

  setup do
    ZiteActiveRecord.site( 'testsite45A67' )
    @user_wido = users(:wido)
    @user_john = users(:john)    
    @session_wido = user_sessions(:session_one)   
    request.host = 'testhost45A67'	    
  end
  
  test "should get who_are_u" do
    
    [true,false].each do |java|                 
        Rails.configuration.use_javascript = java
        @not_java = ! Rails.configuration.use_javascript
        
	    if @not_java
		  begin	
	        get :who_are_u
		  rescue Exception => e
		    puts "strange message in authenticate_controller_test:"
		    puts e		    
		  end
	      assert_response :success
	      assert_select '.form-horizontal'
	      assert_select '.control-label', /username\/email/ 
	    else
	      get :who_are_u, xhr: true
	      assert_response :success
	      assert_select_jquery :html, '#authentication_dialogue_js' do
	        assert_select '.form-horizontal'
	        assert_select '.control-label', /username\/email/ 
	      end
	    end
	end
  end

  test "should post prove_it_with_user_name" do
    [true,false].each do |java|                 
        Rails.configuration.use_javascript = java
        @not_java = ! Rails.configuration.use_javascript  
	    if @not_java
	      post :prove_it, params: { claim: "some weird name" }
	      assert_response :success
	      assert_select '.alert-info', /some weird name/
	      assert_select '.control-label', /password/           
	    else
	      post :prove_it, xhr: true, params: { claim: "some weird name" }
	      assert_response :success       
	      assert_select_jquery :html, '#authentication_dialogue_js' do    
	        assert_select '.alert-info', /some weird name/
	        assert_select '.control-label', /password/
	      end      
	    end
	    assert_equal @controller.session[:password_retries], 0  
	end
  end
  
  test "prove_it with correct password" do
    [true,false].each do |java|                 
        Rails.configuration.use_javascript = java
        @not_java = ! Rails.configuration.use_javascript    
	    @controller.session[:password_retries] = 0
	    if @not_java  
	      post :prove_it, params: { claim: "wido", kennwort: "secret" }
	    else
	      post :prove_it, xhr: true, params: { claim: "wido", kennwort: "secret" }
	    end
	    assert_root_path_redirect    
	    assert_equal flash[:notice], 'wido logged in'
	    assert_nil @controller.session[:password_retries]
	    assert_equal @controller.session[:user_session_id], UserSession.last.id   
    end	    
  end
     
  test "prove_it with incorrect password" do
    [true,false].each do |java|                 
        Rails.configuration.use_javascript = java
        @not_java = ! Rails.configuration.use_javascript    
	    @controller.session[:password_retries] = 0
	    if @not_java
	      post :prove_it, params: { claim: "wido", kennwort: "secret1" }
	      assert_response :success   
	      assert_select '.form-horizontal' 
	      assert_select '.control-label', /password/   
	    else 
	      post :prove_it, xhr: true, params: { claim: "wido", kennwort: "secret1" }
	      assert_response :success 
	      assert_select_jquery :html, '#authentication_dialogue_js' do
	        assert_select '.form-horizontal' 
	        assert_select '.control-label', /password/        
	      end      
	    end      
	    assert_equal assigns(:retries), 1
	    assert_equal assigns(:max_retries), 3
	    assert_equal @controller.session[:password_retries], 1
    end	    
  end  
  
  test "prove_it with incorrect password too often" do
    [true,false].each do |java|                 
        Rails.configuration.use_javascript = java
        @not_java = ! Rails.configuration.use_javascript      
	    @controller.session[:password_retries] = 3
	    if @not_java
	      post :prove_it, params: { claim: "wido", kennwort: "secret1" }
	    else 
	      post :prove_it, xhr: true, params: { claim: "wido", kennwort: "secret1" }
	    end   
	    assert_root_path_redirect    
	    assert_equal flash[:alert], 'user suspended, check your email (including SPAM folder)'      
	    assert_nil @controller.session[:password_retries]
    end	    
  end


  test "prove_it with incorrect password too often email failed" do
    [true,false].each do |java|                 
        Rails.configuration.use_javascript = java
        @not_java = ! Rails.configuration.use_javascript     
	    @controller.session[:password_retries] = 3
	    if @not_java
	      post :prove_it, params: { claim: "wido", kennwort: "secret1", ab47hk: "ab47hk" }
	    else 
	      post :prove_it, xhr: true, params: { claim: "wido", kennwort: "secret1", ab47hk: "ab47hk" }
	    end   
	    assert_root_path_redirect  
	    assert flash[:alert] =~ /sending failed/
    end	    
  end
             
  test "prove_it with suspended user" do
    [true,false].each do |java|                 
        Rails.configuration.use_javascript = java
        @not_java = ! Rails.configuration.use_javascript     
	    if @not_java
	      post :prove_it, params: { claim: "john", kennwort: "secret" }  
	    else 
	      post :prove_it, xhr: true, params: { claim: "john", kennwort: "secret" }
	    end
	    assert_root_path_redirect    
	    assert_equal flash[:alert], 'user is not activated, check your email (including SPAM folder)' 
    end	        
  end  
  
  test "prove_it with noexisting user" do
    [true,false].each do |java|                 
        Rails.configuration.use_javascript = java
        @not_java = ! Rails.configuration.use_javascript     
	    if @not_java
	      post :prove_it, params: { claim: "john1", kennwort: "secret" }
	    else 
	      post :prove_it, xhr: true, params: { claim: "john1", kennwort: "secret" }
	    end
		assert_response :success 
	    assert_nil flash[:alert]
    end	    
  end   
 
  test "prove_it with noexisting user too many retries" do
    [true,false].each do |java|                 
        Rails.configuration.use_javascript = java
        @not_java = ! Rails.configuration.use_javascript   
        @controller.session[:password_retries] = 3		
	    if @not_java
	      post :prove_it, params: { claim: "john1", kennwort: "secret" }
	    else 
	      post :prove_it, xhr: true, params: { claim: "john1", kennwort: "secret" }
	    end
        assert_root_path_redirect    
	    assert_equal flash[:alert], "password for \"john1\" is incorrect!" 
    end	    
  end   
   
  test "about_urself" do
    [true,false].each do |java|                 
        Rails.configuration.use_javascript = java
        @not_java = ! Rails.configuration.use_javascript     
	    if @not_java
	      post :about_urself
	      assert_response :success
	      assert_select '.form-horizontal'       
	      assert_select '.control-label', /username/  
	      assert_select '.control-label', /email/        
	    else  
	      post :about_urself, xhr: true 
	      assert_response :success
	      assert_select_jquery :html, '#authentication_dialogue_js' do
	        assert_select '.form-horizontal'       
	        assert_select '.control-label', /username/  
	        assert_select '.control-label', /email/            
	      end    
	    end
	end
  end
 
  test "about_urself correct credentials" do
    [true,false].each do |java|                 
        Rails.configuration.use_javascript = java
        @not_java = ! Rails.configuration.use_javascript
        
        #because we run this twice...
        jim = User.by_email_or_username('jim')
        jim.destroy if jim
              
	    if @not_java
	      post :about_urself, params: { username: "jim", email: "jim@gmail.com" }
	    else  
	      post :about_urself, xhr: true, params: { username: "jim", email: "jim@gmail.com" }       
	    end
	    assert_root_path_redirect  
	    assert_nil flash[:alert]
	    assert_equal flash[:notice], 
	        "Please check your email jim@gmail.com (including your SPAM folder) for an email to verify it's you and set your password!"
	    assert_equal @controller.session[:user_session_id], UserSession.last.id   
    end	        
  end
         
  test "about_urself correct credentials email send failure" do
    [true,false].each do |java|                 
        Rails.configuration.use_javascript = java
        @not_java = ! Rails.configuration.use_javascript      
	    if @not_java
	      post :about_urself, params: { username: "jim", email: "jim@gmail.com", ab47hk: "ab47hk" }
	    else  
	      post :about_urself, xhr: true, params: { username: "jim", email: "jim@gmail.com", ab47hk: "ab47hk" }   
	    end
	    assert_root_path_redirect  
	    assert flash[:alert] =~ /it failed/
    end	    
  end          

  test "about_urself incorrect credentials - duplicate" do
    [true,false].each do |java|                 
        Rails.configuration.use_javascript = java
        @not_java = ! Rails.configuration.use_javascript      
	    if @not_java
	      post :about_urself, params: { username: "john", email: "john@mmm.com" }
	      assert_response :success
	      assert_select '.form-horizontal' 
	      assert_select '.control-label', /username/           
	      assert_select '.control-label', /email/  
	    else      
	      post :about_urself, xhr: true, params: { username: "john", email: "john@mmm.com" }
	      assert_response :success
	      assert_select_jquery :html, '#authentication_dialogue_js' do
	        assert_select '.form-horizontal' 
	        assert_select '.control-label', /username/           
	        assert_select '.control-label', /email/                   
	      end         
	    end
	    assert_equal assigns(:current_user).errors.count, 2
	    assert_equal assigns(:current_user).errors.full_messages[0], "Username has already been taken"
	    assert_equal assigns(:current_user).errors.full_messages[1], "Email has already been taken"
    end	    
  end

  test "about_urself incorrect credentials - bad email" do
    [true,false].each do |java|                 
        Rails.configuration.use_javasc=endript = java
        @not_java = ! Rails.configuration.use_javascript      
	    if @not_java
	      post :about_urself, params: { username: "john17", email: "whatever" }
	      assert_response :success
	      assert_select '.form-horizontal' 
	      assert_select '.control-label', /username/           
	      assert_select '.control-label', /email/  
	    else      
	      post about_urself, xhr: true, params: { username: "john17", email: "whatever" }
	      assert_response :success
	      assert_select_jquery :html, '#authentication_dialogue_js' do
	        assert_select '.form-horizontal' 
	        assert_select '.control-label', /username/           
	        assert_select '.control-label', /email/                   
	      end         
	    end
	    assert_equal assigns(:current_user).errors.count, 1
	    assert_equal assigns(:current_user).errors.full_messages[0], "Email not a valid email address"
    end	    
  end  
   
  test "about_urself duplicate credentials other site" do
    [true,false].each do |java|                 
        Rails.configuration.use_javascript = java
        @not_java = ! Rails.configuration.use_javascript

        ZiteActiveRecord.site( 'othersite45A67' )
        request.host = 'othersite45A67'		
        
        #because we run this twice...
        john = User.by_email_or_username('john')
        john.destroy if john
           
	    if @not_java
	      post :about_urself, params: { username: "john", email: "john@mmm.com" }
	    else      
	      post :about_urself, xhr: true, params: { username: "john", email: "john@mmm.com" }   
	    end

	    assert_equal assigns(:current_user).errors.count, 0
    end	    
  end
    
  test "from_mail get without token" do    
    get :from_mail, params: { user_token: 'bla' }    
    assert_redirected_to root_path   
    assert_equal flash[:alert], "the activation link is incorrect, please reset..."  
  end
  
  test "from_mail get with correct token" do
    get :from_mail, params: { user_token: 'john_token' }  
    assert_equal flash[:alert], "please set your password"
    assert_redirected_to root_path   
    assert_equal session[:reset_user_id], @user_john.id
  end
 
  test "from_mail get with incorrect token" do
    @user_john.token = 'a1b2'
    @user_john.password = @user_john.password_confirmation = 'bla'
    @user_john.save!
    get :from_mail, params: { user_token: 'john_token' }
    assert_equal flash[:alert], "the activation link is incorrect, please reset..."		
	assert_nil session[:reset_user_id]			
	assert_redirected_to root_path   	       
  end    

  test "ur_secrets from mail post without anything" do
    [true,false].each do |java|                 
        Rails.configuration.use_javascript = java
        @not_java = ! Rails.configuration.use_javascript     
	    session[:reset_user_id] = @user_john.id         
	    if @not_java
	      post :ur_secrets
	      assert_response :success
	      assert_select '.form-horizontal'
	      assert_select '.alert-info', /#{@user_john.username}/
	      assert_select '.control-label', /password/ 
	      assert_select '.control-label', /confirmation/     
	    else
	      post :ur_secrets, xhr: true 
	      assert_response :success
	      assert_select_jquery :html, '#authentication_dialogue_js' do
	        assert_select '.form-horizontal'
	        assert_select '.alert-info', /#{@user_john.username}/
	        assert_select '.control-label', /password/ 
	        assert_select '.control-label', /confirmation/            
	      end           
	    end
	    assert_equal assigns(:current_user).errors.count, 2
	    assert_equal assigns(:current_user).errors.full_messages[0], "Password is too short (minimum is 3 characters)"
	    assert_equal assigns(:current_user).errors.full_messages[1], "Password can't be blank"
	    assert_nil session[:reset_user_id]
    end	    
  end  

  test "ur_secrets post with correct user_id" do
    [true,false].each do |java|                 
        Rails.configuration.use_javascript = java
        @not_java = ! Rails.configuration.use_javascript       
	    if @not_java
	      post :ur_secrets, params: { user_id: @user_john.id }
	      assert_response :success
	      assert_select '.form-horizontal'
	      assert_select '.control-label', /password/ 
	      assert_select '.control-label', /confirmation/      
	    else
	      post :ur_secrets, xhr: true, params: { user_id: @user_john.id }
	      assert_response :success      
	      assert_select_jquery :html, '#authentication_dialogue_js' do
	        assert_select '.form-horizontal'
	        assert_select '.control-label', /password/ 
	        assert_select '.control-label', /confirmation/            
	      end           
	    end
	    assert_equal assigns(:current_user).errors.count, 2
	    assert_equal assigns(:current_user).errors.full_messages[0], "Password is too short (minimum is 3 characters)"
	    assert_equal assigns(:current_user).errors.full_messages[1], "Password can't be blank"
	    assert_nil session[:reset_user_id]
    end	    
  end 
  
  test "ur_secrets post with incorrect user_id" do
    [true,false].each do |java|                 
        Rails.configuration.use_javascript = java
        @not_java = ! Rails.configuration.use_javascript       
	    if @not_java
	      post :ur_secrets, params: { user_id: 27 }
	    else
	      post :ur_secrets, xhr: true, params: { user_id: 27 }
	    end
	    assert_root_path_redirect    
	    assert_equal flash[:alert], "leopards in the bushes!"
	    assert_nil session[:reset_user_id]
    end	    
  end    

  test "ur_secrets post with correct user_id and not matching passwords" do
    [true,false].each do |java|                 
        Rails.configuration.use_javascript = java
        @not_java = ! Rails.configuration.use_javascript       
	    if @not_java
	      post :ur_secrets, params: { user_id: @user_john.id, kennwort: 'secret', confirmation: 'secret2' }
	      assert_response :success
	      assert_select '.form-horizontal'    
	      assert_select '.control-label', /password/ 
	      assert_select '.control-label', /confirmation/         
	    else
	      post :ur_secrets, xhr: true, params: { user_id: @user_john.id, kennwort: 'secret', confirmation: 'secret2' }
	      assert_response :success
	      assert_select_jquery :html, '#authentication_dialogue_js' do
	        assert_select '.form-horizontal'
	        assert_select '.control-label', /password/ 
	        assert_select '.control-label', /confirmation/            
	      end  
	    end
	    assert_equal assigns(:current_user).errors.count, 1
	    assert_equal assigns(:current_user).errors.full_messages[0], "Password confirmation doesn't match Password"
	    assert_nil session[:reset_user_id]
    end	    
  end 

  test "ur_secrets post with correct user_id and correct passwords" do
    [true,false].each do |java|                 
        Rails.configuration.use_javascript = java
        @not_java = ! Rails.configuration.use_javascript       
	    if @not_java
	      post :ur_secrets, params: { user_id: @user_john.id, kennwort: 'secret', confirmation: 'secret' }
	    else
	      post :ur_secrets, xhr: true, params: { user_id: @user_john.id, 
	                        kennwort: 'secret', confirmation: 'secret' }
	    end
	    assert_root_path_redirect
	    assert_equal flash[:notice], "password set, you are logged in!"
	    assert_equal @controller.session[:user_session_id], UserSession.last.id 
    end	    
  end 

  test "reset_mail" do
    @controller.session[:user_session_id] = @session_wido.id
    get :reset_mail, params: { claim: "wido" }
    assert_redirected_to root_path
    assert_equal flash[:notice], "user wido suspended, check your email (including SPAM folder)"
    assert_nil @controller.session[:user_session_id]      
  end
  
  test "reset_mail invalid" do
    get :reset_mail, params: { claim: "wido1" }
    assert_redirected_to root_path
    assert_nil @controller.session[:user_session_id]        
  end  
  
  test "see u" do
    session[:reset_user_id] = 77
    @controller.session[:user_session_id] = @session_wido.id
    get :see_u
    assert_redirected_to root_path
    assert_not @response.body =~ /window.location/  
    assert_nil @controller.session[:user_session_id]
    assert_nil session[:reset_user_id]
  end

  private
  
    def root_path
      Rails.application.class.routes.url_helpers.root_path 
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