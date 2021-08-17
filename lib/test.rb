
require 'openssl'

require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)

puts "test"

ZiteActiveRecord.site( "www.menhardt.com" )
@user_sessions = UserSession.all.order( updated_at: :desc )

i_requests = 0            
@user_sessions.each do |u|

=begin
  if u.isp and u.isp.includes?("ParserError")
    u.isp = nil
    u.save
  end
=end
  
  if !u.isp 
    i_requests = i_requests + 1
    u.isp = GeoIp.getcountryandorg(u.ip)
    p u.ip
    p u.isp
    if u.isp
      u.save
      puts "saved"
    end
    puts
    break if i_requests > 20
  end
  
end
