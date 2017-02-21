require 'test_helper'
require 'pp'

class AuthenticationNotifierTest < ActionMailer::TestCase
  

  setup do
    ZiteActiveRecord.site( 'testsite45A67' )  	    
  end
	  
  test "registration" do
    @current_user = users( :john )
    @request = ActionController::TestRequest.create
    @path = @request.protocol + @request.host + ':' + @request.port.to_s +
              '/_from_mail/' +  @current_user.token               
    mail = AuthenticationNotifier.registration( @current_user, @request, ['a@a.com', 'b@b.com'] )
    assert_equal "Registration information for test.host", mail.subject
    assert_equal [@current_user.email], mail.to
    assert_equal ["noreply@okaapi.com"], mail.from
    assert_equal ['a@a.com', 'b@b.com'], mail.bcc
    assert_equal "test.host Authentication <noreply@okaapi.com>", mail['from'].value
    assert_equal "Registration information for test.host", mail.subject
    assert_match @path, mail.body.encoded
    assert_match 'john_token', mail.body.encoded
    assert_match 'test.host', mail.body.encoded      
  end
  test "reset" do
    @current_user = users( :john )
    @request = ActionController::TestRequest.create
    @path = @request.protocol + @request.host + ':' + @request.port.to_s +
              '/_from_mail/' +  @current_user.token    
    mail = AuthenticationNotifier.reset( @current_user, @request, 'a@a.com' )
    assert_equal "Password reset information for test.host", mail.subject
    assert_equal [@current_user.email], mail.to
    assert_equal ["noreply@okaapi.com"], mail.from
    assert_equal ["a@a.com"], mail.bcc    
    assert_equal "Password reset information for test.host", mail.subject    
    assert_match @path, mail.body.encoded
    assert_match 'john_token', mail.body.encoded
    assert_match 'test.host', mail.body.encoded    
  end
  test "test" do
    @current_user = users( :john )
    mail = AuthenticationNotifier.test( @current_user.email )
    assert_equal mail.subject, 'Okaapi test'
  end

end

