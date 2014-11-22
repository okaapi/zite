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

  # Add more helper methods to be used by all tests here...
  
  (1..10).each {puts "."}

def admin_login_4_test
    @admin = users(:admin)
    user_session = UserSession.create( user_id: @admin.id )
    user_session.save!
    session[:user_session_id] = user_session.id
end
end

