require 'test_helper'

class AuthenticationNotifierTest < ActionMailer::TestCase
  

  setup do
    ZiteActiveRecord.site( 'testsite45A67' )  	    
  end
	  
  test "registration" do
    @current_user = users( :john )
    @request = ActionController::TestRequest.new
    @path = @request.protocol + @request.host + ':' + @request.port.to_s +
              '/_from_mail/' +  @current_user.token               
    mail = AuthenticationNotifier.registration( @current_user, @request )
    assert_equal "Okaapi registration confirmation", mail.subject
    assert_equal [@current_user.email], mail.to
    assert_equal ["noreply@okaapi.com"], mail.from
    assert_match @path, mail.body.encoded
    assert_match 'john_token', mail.body.encoded
  end
  test "reset" do
    @current_user = users( :john )
    @request = ActionController::TestRequest.new
    @path = @request.protocol + @request.host + ':' + @request.port.to_s +
              '/_from_mail/' +  @current_user.token    
    mail = AuthenticationNotifier.reset( @current_user, @request )
    assert_equal "Okaapi password reset", mail.subject
    assert_equal [@current_user.email], mail.to
    assert_equal ["noreply@okaapi.com"], mail.from
    assert_match @path, mail.body.encoded
    assert_match 'john_token', mail.body.encoded
  end
  test "test" do
    @current_user = users( :john )
    mail = AuthenticationNotifier.test( @current_user.email )
    assert_equal mail.subject, 'Okaapi test'
  end

end

