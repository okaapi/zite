require 'test_helper'

module Auth
  
class UserTest < ActiveSupport::TestCase
  
  setup do
    ZiteActiveRecord.site( 'testsite45A67' )
    @wido = users(:wido)    
  end
  
  test 'find user by primary email' do
    u = User.find_by_email_or_alternate( 'wido@mmm.com')
    assert_equal u.id, @wido.id
  end
  
  test 'find user by alternate email' do
    u = User.find_by_email_or_alternate( 'wido@mmm.com')
    assert_equal u.id, @wido.id   
  end
  
  test 'find user by wrong email' do
    u = User.find_by_email_or_alternate( 'wido@okaapi.com')
    assert_not u
  end
  
end

end
