require 'test_helper'

module Auth
  
  class UserSessionTest < ActiveSupport::TestCase
  
    setup do
      ZiteActiveRecord.site( 'testsite45A67' )
      @wido = users(:wido)    
    end

	test 'remember' do
	  us = UserSession.create
	  us.remember
	  assert( us.remember_check( us.remember_token ) )
	end
	
	test 'user_session cascade delete' do

	  assert User
	  u = User.first
	  us = UserSession.create( user_id: u.id )
	  us.save!
	  ua1 = UserAction.create( user_session_id: us.id )
	  ua1.save!
	  ua2 = UserAction.create( user_session_id: us.id )	  
	  ua2.save!
	  
	  assert_not_nil UserSession.find( us.id )
	  assert_not_nil UserAction.find( ua1.id )
	  assert_not_nil UserAction.find( ua2.id )	  
	  
	  us.destroy
	  assert !UserSession.exists?( us.id )
	  assert !UserAction.exists?( ua1.id )
	  assert !UserAction.exists?( ua2.id )	  
	  
	  
	end
	
	#
	#  this is a bug in rails where user_session.user may not fetch the right user 
	#  object depending on the "site" scope
	#  see <==============  for what fails...
	#  11 Oct 2018: seems to work now....?
	#
    test 'user_session.user fails...' do

      ZiteActiveRecord.site( 'a' ) 	
      u = User.by_email_or_username( 'a1' )
	  u.destroy if u	
      u = User.create( username: 'a1', email: 'a1@gmail.com', password: 'aaa', password_confirmation: 'aaa' )
      u.save!
	  assert_not_nil (uid_a = u.id)
	  us = UserSession.create( user_id: uid_a )
	  us.remember
	  us.save!
	  assert_not_nil (usid_a = us.id)
	  assert_not_nil (usid_art = us.remember_token)

      ZiteActiveRecord.site( 'b' )
      u = User.by_email_or_username( 'a1' )
	  u.destroy if u	
      u = User.create( username: 'a1', email: 'a1@outlook.com', password: 'aaa', password_confirmation: 'aaa' )
      u.save!
      assert_not_nil (uid_b = u.id)
	  us = UserSession.create( user_id: uid_b )
	  us.remember	  
	  us.save!	  
	  assert_not_nil (usid_b = us.id)	
	  assert_not_nil (usid_brt = us.remember_token)	  
	  
	  ZiteActiveRecord.site( 'a' ) 
	  usa = UserSession.recover( usid_a, usid_art )
	  assert_not_nil usa
	  assert_equal usa.user_id, uid_a
	  usb = UserSession.recover( usid_b, usid_brt )
	  assert_nil usb  
	  ua = usa._user
	  assert_equal ua.id, uid_a
	  assert_equal ua.site, 'a'
	  ua = usa.user   #<==============
	  assert_equal ua.id, uid_a
	  assert_equal ua.site, 'a'
	  
	  ZiteActiveRecord.site( 'b' ) 
	  usa = UserSession.recover( usid_a, usid_art )
	  assert_nil usa
	  usb = UserSession.recover( usid_b, usid_brt )
	  assert_not_nil usb  
	  assert_equal usb.user_id, uid_b
	  ub = usb._user	  
      assert_equal ub.id, uid_b
	  assert_equal ub.site, 'b'	  
  	  ub = usb.user	  #<==============   
      assert_equal ub.id, uid_b
	  assert_equal ub.site, 'b'	  
	  
    end
	
  end

end


