require 'test_helper'

module Admin

  class UserSessionsControllerTest < ActionController::TestCase
    setup do 
      ZiteActiveRecord.site( 'testsite45A67' )
      @user_session = user_sessions(:session_one)
      admin_login_4_test
	  request.host = 'testhost45A67'	          
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:user_sessions)
    end
    
    test "should get index ip order" do
      get :index, by_ip: 'true'
      assert_response :success
      assert_not_nil assigns(:user_sessions)
    end
    
    test "should get index name order" do
      get :index, by_name: 'true'
      assert_response :success
      assert_not_nil assigns(:user_sessions)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create user_session" do
      @controller.session[:user_session_id] = @user_session.id
      assert_difference('UserSession.count', 1) do
        post :create, user_session: { user_id: users(:wido).id }    
      end
      assert_redirected_to user_session_path(assigns(:user_session))    
      assert_equal assigns(:user_session).user, users(:wido)
    end
   
  
    test "should create user_session without user" do
      @controller.session[:user_session_id] = @user_session.id
      assert_difference('UserSession.count') do
        post :create, user_session: { ip: "dummy"  }
      end
      assert_redirected_to user_session_path(assigns(:user_session))
      assert_not assigns(:user_session).user
    end  
  
    test "should not create user_session with invalid user" do
      @controller.session[:user_session_id] = @user_session.id
      assert_no_difference('UserSession.count') do
        post :create, user_session: { user_id: 7 }
      end    
      assert_response :success
      assert_select "li", /User has to be valid/
    end
    
    test "should show user_session" do
      get :show, id: @user_session
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @user_session
      assert_response :success
    end
  
    test "should update user_session" do
      patch :update, id: @user_session, user_session: { user_id: @user_session.user_id }
      assert_redirected_to user_session_path(assigns(:user_session))
    end
  
    test "should destroy user_session and its actions" do
      @controller.session[:user_session_id] = @user_session.id
      assert_difference('UserSession.count', -1) do
        assert_difference('UserAction.count', -2) do
          delete :destroy, id: @user_session
        end
      end
  
      assert_redirected_to user_sessions_path
    end
  
  end

end
	    
