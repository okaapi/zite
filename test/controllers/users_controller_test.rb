require 'test_helper'



class UsersControllerTest < ActionController::TestCase

  setup do
    @user = users(:wido)
    admin_login_4_test
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end
  
  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user" do
    assert_difference('User.count') do
      post :create, user: { email: "a@menhardt.com", username: "peter",
        password: 'secret', password_confirmation: 'secret' }
    end
    assert_redirected_to user_path(assigns(:user))
  end
  
  test "should not create user with unmatching password confirmation" do
    assert_no_difference('User.count') do
      post :create, user: { email: "a@menhardt.com", username: "peter",
        password: 'secret', password_confirmation: 'secret_different' }
    end
    assert_response :success
  end
  
  test "should not create user if password too short" do
    assert_no_difference('User.count') do
      post :create, user: { email: "a@menhardt.com", username: "peter",
        password: 'aa', password_confirmation: 'aa' }
    end
    assert_response :success
  end  
  
  test "should not create user with same name" do
    assert_no_difference('User.count') do
      post :create, user: { email: "a@menhardt.com", username: "wido",
        password: 'secret', password_confirmation: 'secret' }
    end
    assert_response :success
  end  

  test "should not create user without name" do
    assert_no_difference('User.count') do
      post :create, user: { email: "a@menhardt.com", username: "",
        password: 'secret', password_confirmation: 'secret' }
    end
    assert_response :success
  end
 
  test "should not create user with incorrect name" do
    assert_no_difference('User.count') do
      post :create, user: { email: "a@menhardt.com", username: "wido",
        password: 'secret', password_confirmation: 'secret' }
    end
    assert_response :success
  end


  test "should not create user with  same email" do
    assert_no_difference('User.count') do
      post :create, user: { email: "wido@menhardt.com", username: "peter",
        password: 'secret', password_confirmation: 'secret' }
    end
    assert_response :success
  end
       
  test "should not create user without email" do
    assert_no_difference('User.count') do
      post :create, user: { email: "", username: "peter",
        password: 'secret', password_confirmation: 'secret' }
    end
    assert_response :success
  end

  test "should not create user with  incorrect email" do
    assert_no_difference('User.count') do
      post :create, user: { email: "something", username: "peter",
        password: 'secret', password_confirmation: 'secret' }
    end
    assert_response :success
  end
  
  test "should show user" do
    get :show, id: @user
    assert_response :success
  end
  
  test "should get edit" do
    get :edit, id: @user
    assert_response :success
  end

  test "should update user" do
    patch :update, id: @user, user: { active: @user.active, 
       email: "b@menhardt.com", password: 'secret', 
       password_confirmation: 'secret', role: @user.role, username: "felix" }
    assert_redirected_to user_path(assigns(:user))
  end

  test "should destroy user and its sessions and their actions" do
    assert_difference('User.count', -1) do
      assert_difference('UserSession.count', -2) do
        assert_difference('UserAction.count', -1) do
          delete :destroy, id: @user               
        end
      end
    end
   
    assert_redirected_to users_path    
    
  end 

end

