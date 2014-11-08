require 'test_helper'

class SeiteControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get pageupdate" do
    get :pageupdate
    assert_redirected_to '/'
  end

end
