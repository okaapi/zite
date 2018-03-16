require 'test_helper'

module Auth
  
  class UserSessionTest < ActiveSupport::TestCase
  
    setup do
      ZiteActiveRecord.site( 'testsite45A67' )
      @wido = users(:wido)    
    end

	#
	#  this is a bug in rails where user_session.user may not fetch the right user 
	#  object depending on the "site" scope
	#  see <==============  for what fails...
	#
    test 'user_session.user fails...' do

      ZiteActiveRecord.site( 'a' ) 	
      u = User.by_email_or_username( 'a1' )
	  u.destroy if u	
      u = User.create( username: 'a1', email: 'a1@gmail.com', password: 'aaa', password_confirmation: 'aaa' )
      u.save!
	  assert_not_nil (uid_a = u.id)
	  us = UserSession.create( user_id: uid_a )
	  us.save!
	  assert_not_nil (usid_a = us.id)

      ZiteActiveRecord.site( 'b' )
      u = User.by_email_or_username( 'a1' )
	  u.destroy if u	
      u = User.create( username: 'a1', email: 'a1@gmail.com', password: 'aaa', password_confirmation: 'aaa' )
      u.save!
      assert_not_nil (uid_b = u.id)
	  us = UserSession.create( user_id: uid_b )
	  us.save!	  
	  assert_not_nil (usid_b = us.id)	  
	  
	  ZiteActiveRecord.site( 'a' ) 
	  usa, idle = UserSession.recover( usid_a )
	  assert_not_nil usa
	  assert_equal usa.user_id, uid_a
	  usb, idle = UserSession.recover( usid_b )
	  assert_nil usb  
	  # ua = usa.user   <==============
	  ua = usa._user
	  assert_equal ua.id, uid_a
	  assert_equal ua.site, 'a'

	  ZiteActiveRecord.site( 'b' ) 
	  usa, idle = UserSession.recover( usid_a )
	  assert_nil usa
	  usb, idle = UserSession.recover( usid_b )
	  assert_not_nil usb  
	  assert_equal usb.user_id, uid_b
	  # ub = usb.user	  <==============
	  ub = usb._user	  
      assert_equal ub.id, uid_b
	  assert_equal ub.site, 'b'	  
  
    end
	
end

end
