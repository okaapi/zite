require 'bcrypt'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'simplecov'
SimpleCov.start do
end
puts "simple cov started"

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
 
  (1..10).each {puts "."}
  puts "[ javascript is " + ( Rails.configuration.use_javascript ? "on ]" : "off ]" ) 
  puts "[ caching is " + ( Rails.configuration.page_caching ? "on ]" : "off ]" )   


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

end

