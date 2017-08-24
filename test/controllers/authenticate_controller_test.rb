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
    
		  begin	
	        get :who_are_u
		  rescue Exception => e
		    puts "strange message in authenticate_controller_test:"
		    puts e		    
		  end
	      assert_response :success
	      assert_select '.form-horizontal'
	      assert_select '.control-label', /username or email/ 


  end
    
  test "should post prove_it_with_user_name" do

	      post :prove_it, params: { claim: "some weird name" }
	      assert_response :success
	      assert_select '.alert-info', /some weird name/
	      assert_select '.control-label', /password/           

	    assert_equal @controller.session[:password_retries], 0  

  end
  
  test "prove_it with correct password" do

	    @controller.session[:password_retries] = 0

	      post :prove_it, params: { claim: "wido", kennwort: "secret" }

	    assert_root_path_redirect    
	    assert_equal flash[:notice], 'wido logged in'
	    assert_nil @controller.session[:password_retries]
	    assert_equal @controller.session[:user_session_id], UserSession.last.id   
   
  end

  test "prove_it with incorrect password" do

	    @controller.session[:password_retries] = 0

	      post :prove_it, params: { claim: "wido", kennwort: "secret1" }
	      assert_response :success   
	      assert_select '.form-horizontal' 
	      assert_select '.control-label', /password/   
  
	    assert_equal assigns(:retries), 1
	    assert_equal assigns(:max_retries), 3
	    assert_equal @controller.session[:password_retries], 1

  end  
  
  test "prove_it with incorrect password too often" do
    
	    @controller.session[:password_retries] = 3

	      post :prove_it, params: { claim: "wido", kennwort: "secret1" }

	    assert_root_path_redirect    
	    assert_equal flash[:alert], 'user suspended, check your email (including SPAM folder)'      
	    assert_nil @controller.session[:password_retries]

  end



  test "prove_it with incorrect password too often email failed" do
  
	    @controller.session[:password_retries] = 3

	      post :prove_it, params: { claim: "wido", kennwort: "secret1", ab47hk: "ab47hk" }

	    assert_root_path_redirect  
	    assert flash[:alert] =~ /sending failed/
   
  end
             
  test "prove_it with suspended user" do
	      post :prove_it, params: { claim: "john", kennwort: "secret" }  

	    assert_root_path_redirect    
	    assert_equal flash[:alert], 'user is not activated, check your email (including SPAM folder)' 
      
  end  
 
  
  test "prove_it with noexisting user" do

	      post :prove_it, params: { claim: "john1", kennwort: "secret" }

		assert_response :success 
	    assert_nil flash[:alert]
 
  end   
 
  test "prove_it with noexisting user too many retries" do

        @controller.session[:password_retries] = 3		

	      post :prove_it, params: { claim: "john1", kennwort: "secret" }

        assert_root_path_redirect    
	    assert_equal flash[:alert], "password for \"john1\" is incorrect!" 
   
  end   
      
  test "about_urself" do

	      post :about_urself
	      assert_response :success
	      assert_select '.form-horizontal'       
	      assert_select '.control-label', /username/  
	      assert_select '.control-label', /email/        


  end
 
  test "about_urself correct credentials" do

        
        #because we run this twice...
        jim = User.by_email_or_username('jim')
        jim.destroy if jim
              

	      post :about_urself, params: { username: "jim", email: "jim@gmail.com" }

	    assert_root_path_redirect  
	    assert_nil flash[:alert]
	    assert_equal flash[:notice], 
	        "Please check your email jim@gmail.com (including your SPAM folder) for an email to verify it's you and set your password!"
	    assert_equal @controller.session[:user_session_id], UserSession.last.id   
       
  end
     
  test "about_urself correct credentials email send failure" do

	      post :about_urself, params: { username: "jim", email: "jim@gmail.com", ab47hk: "ab47hk" }

	      post :about_urself, xhr: true, params: { username: "jim", email: "jim@gmail.com", ab47hk: "ab47hk" }   

	    assert_root_path_redirect  
	    assert flash[:alert] =~ /it failed/
   
  end          

  test "about_urself incorrect credentials - duplicate" do

	      post :about_urself, params: { username: "john", email: "john@mmm.com" }
	      assert_response :success
	      assert_select '.form-horizontal' 
	      assert_select '.control-label', /username/           
	      assert_select '.control-label', /email/  

	    assert_equal assigns(:current_user).errors.count, 2
	    assert_equal assigns(:current_user).errors.full_messages[0], "Username has already been taken"
	    assert_equal assigns(:current_user).errors.full_messages[1], "Email has already been taken"
    
  end

  test "about_urself incorrect credentials - bad email" do

	      post :about_urself, params: { username: "john17", email: "whatever" }
	      assert_response :success
	      assert_select '.form-horizontal' 
	      assert_select '.control-label', /username/           
	      assert_select '.control-label', /email/  

	    assert_equal assigns(:current_user).errors.count, 1
	    assert_equal assigns(:current_user).errors.full_messages[0], "Email not a valid email address"
	    
  end  
   
  test "about_urself duplicate credentials other site" do


        ZiteActiveRecord.site( 'othersite45A67' )
        request.host = 'othersite45A67'		
        
        #because we run this twice...
        john = User.by_email_or_username('john')
        john.destroy if john
           

	      post :about_urself, params: { username: "john", email: "john@mmm.com" }


	    assert_equal assigns(:current_user).errors.count, 0
  
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
	    session[:reset_user_id] = @user_john.id         
	      post :ur_secrets
	      assert_response :success
	      assert_select '.form-horizontal'
	      assert_select '.alert-info', /#{@user_john.username}/
	      assert_select '.control-label', /password/ 
	      assert_select '.control-label', /confirmation/     
	    assert_equal assigns(:current_user).errors.count, 2
	    assert_equal assigns(:current_user).errors.full_messages[0], "Password is too short (minimum is 3 characters)"
	    assert_equal assigns(:current_user).errors.full_messages[1], "Password can't be blank"
	    assert_nil session[:reset_user_id]    
  end  

  test "ur_secrets post with correct user_id" do
    post :ur_secrets, params: { user_id: @user_john.id }
    assert_response :success
    assert_select '.form-horizontal'
    assert_select '.control-label', /password/ 
    assert_select '.control-label', /confirmation/      
    assert_equal assigns(:current_user).errors.count, 2
    assert_equal assigns(:current_user).errors.full_messages[0], "Password is too short (minimum is 3 characters)"
    assert_equal assigns(:current_user).errors.full_messages[1], "Password can't be blank"
    assert_nil session[:reset_user_id] 
  end 
  
  test "ur_secrets post with incorrect user_id" do
    post :ur_secrets, params: { user_id: 27 }
    assert_root_path_redirect    
    assert_equal flash[:alert], "leopards in the bushes!"
    assert_nil session[:reset_user_id]
	    
  end    

  test "ur_secrets post with correct user_id and not matching passwords" do
	post :ur_secrets, params: { user_id: @user_john.id, kennwort: 'secret', confirmation: 'secret2' }
	assert_response :success
	assert_select '.form-horizontal'    
	assert_select '.control-label', /password/ 
	assert_select '.control-label', /confirmation/         
	assert_equal assigns(:current_user).errors.count, 1
	assert_equal assigns(:current_user).errors.full_messages[0], "Password confirmation doesn't match Password"
	assert_nil session[:reset_user_id]  
  end 

  test "ur_secrets post with correct user_id and correct passwords" do
    post :ur_secrets, params: { user_id: @user_john.id, kennwort: 'secret', confirmation: 'secret' }
	assert_root_path_redirect
	assert_equal flash[:notice], "password set, you are logged in!"
	assert_equal @controller.session[:user_session_id], UserSession.last.id 
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
      
  test "reset session" do
    get :who_are_u
    assert_response :success
    assert_not_nil @controller.session[:user_session_id]	
    get :clear
    assert_redirected_to '/'
	assert_nil @controller.session[:user_session_id]	
    assert_equal flash[:alert], 'session reset...'		
  end
  
  test "check" do
    get :check
	assert_redirected_to '/'
	get :check, params: { code: 17706 }
    assert_response :success  
  end  

  private
  
    def root_path
      Rails.application.class.routes.url_helpers.root_path 
    end
    
    def assert_root_path_redirect
      assert_redirected_to root_path
      assert @response.body =~ /redirected/  
    end
    
end