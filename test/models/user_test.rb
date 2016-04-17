require 'test_helper'

module Auth
  
class UserTest < ActiveSupport::TestCase
  
  setup do
    ZiteActiveRecord.site( 'testsite45A67' )
    @wido = users(:wido)    
  end
  
  test 'get user by primary email' do
    u = User.by_email_or_alternate( 'wido@mmm.com')
    assert_equal u.id, @wido.id
  end
  
  test 'get user by alternate email' do
    u = User.by_email_or_alternate( 'wido@mmm.com')
    assert_equal u.id, @wido.id   
  end
  
  test 'get user by wrong email' do
    u = User.by_email_or_alternate( 'wido@okaapi.com')
    assert_not u
  end
  
  test 'admin_emails' do
    assert_equal ["wido_admin@mmm.com", "wido@mmm.com"], User.admin_emails
  end
  
  test 'test site allocation' do
  	
    ZiteActiveRecord.site( 'a' ) 	
    u = User.by_email_or_username( 'a1' )
	u.destroy if u	
    u = User.create( username: 'a1', email: 'a1@gmail.com', password: 'aaa', password_confirmation: 'aaa' )
    u.save!
	assert_not_nil (uid_a = u.id)

    ZiteActiveRecord.site( 'b' )
    u = User.by_email_or_username( 'a1' )
	u.destroy if u	
    u = User.create( username: 'a1', email: 'a1@gmail.com', password: 'aaa', password_confirmation: 'aaa' )
    u.save!
    assert_not_nil (uid_b = u.id)

    ZiteActiveRecord.site( 'a' )
    u = User.by_email_or_username( 'a1' )
    assert_equal u.id, uid_a
    ZiteActiveRecord.site( 'b' )
    u = User.by_email_or_username( 'a1' )
    assert_equal u.id, uid_b
	
  end
  
  #
  #  find does not answer to the "site" scope...  
  #  see <==============  for what fails...
  #
  test 'test site allocation f ind rails bug' do

    ZiteActiveRecord.site( 'a' ) 	
    u = User.by_email_or_username( 'a1' )
	u.destroy if u	
    u = User.create( username: 'a1', email: 'a1@gmail.com', password: 'aaa', password_confirmation: 'aaa' )
    u.save!
	assert_not_nil (uid_a = u.id)

    ZiteActiveRecord.site( 'b' )
    u = User.by_email_or_username( 'a1' )
	u.destroy if u	
    u = User.create( username: 'a1', email: 'a1@gmail.com', password: 'aaa', password_confirmation: 'aaa' )
    u.save!
    assert_not_nil (uid_b = u.id)

	
    ZiteActiveRecord.site( 'a' )
    #u = User.find_by_username( 'a1' ) <====================
	u = User.where( username: 'a1' ).take
    assert_not_nil u
	assert_equal u.id, uid_a
	
    ZiteActiveRecord.site( 'b' )
    #u = User.find_by_username( 'a1' ) <====================
	u = User.where( username: 'a1' ).take
    assert_not_nil u
	assert_equal u.id, uid_b

  end

end

end
