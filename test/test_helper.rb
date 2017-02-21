require 'bcrypt'
require 'fileutils'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

ActiveRecord::Migration.maintain_test_schema!

require 'simplecov'
SimpleCov.start do
end
puts "simple cov started"

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  
  (1..10).each {puts "."}
  if Rails.configuration.respond_to? 'page_caching'
    puts "[ caching is " + ( Rails.configuration.page_caching ? "on ]" : "off ]" )   
  end
  
  def admin_login_4_test
	@admin = users(:admin)
	user_session = UserSession.create( user_id: @admin.id )
	user_session.save!
	session[:user_session_id] = user_session.id
  end
  def login_4_test
	@current_user = users(:arnaud)
	user_session = UserSession.create( user_id: @current_user.id )
	user_session.save!
	session[:user_session_id] = user_session.id
  end
  def make_cache_directories( external_host )
    cachedir = File.join( Rails.root , 'public', 'cache' )    
    if !Dir.exists? cachedir
      Dir.mkdir cachedir
    end
    if external_host
      cache_directory = File.join( Rails.root , 'public/cache', external_host )    
	  if ! Dir.exists? cache_directory
	    Dir.mkdir cache_directory
	  end  
	end  
  end
  def delete_cache_directories_with_content
    FileUtils.rm_rf( File.join( Rails.root , 'public/cache/othersite45A67' )  )
    FileUtils.rm_rf( File.join( Rails.root , 'public/cache/testhost45A67' )  )
  end
  def delete_storage_directories_with_content
    FileUtils.rm_rf( File.join( Rails.root , 'public/storage/testsite45A67' )  )
  end

end

