require 'test_helper'

class AuthenticationNotifierTest < ActionMailer::TestCase
  
  test "registration" do
    @user = users( :john )
    @request = ActionController::TestRequest.new
    @path = @request.protocol + @request.host + ':' + @request.port.to_s +
              '/_from_mail/' +  @user.token    
    mail = AuthenticationNotifier.registration( @user, @request )
    assert_equal "Okaapi registration confirmation", mail.subject
    assert_equal [@user.email], mail.to
    assert_equal ["email@okaapi.com"], mail.from
    assert_match @path, mail.body.encoded
    assert_match 'john_token', mail.body.encoded
  end
  test "reset" do
    @user = users( :john )
    @request = ActionController::TestRequest.new
    @path = @request.protocol + @request.host + ':' + @request.port.to_s +
              '/_from_mail/' +  @user.token    
    mail = AuthenticationNotifier.reset( @user, @request )
    assert_equal "Okaapi password reset", mail.subject
    assert_equal [@user.email], mail.to
    assert_equal ["email@okaapi.com"], mail.from
    assert_match @path, mail.body.encoded
    assert_match 'john_token', mail.body.encoded
  end

end
