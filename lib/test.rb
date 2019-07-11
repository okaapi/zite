
require 'openssl'

require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)

ip = '134.217.165.65'
puts ip
puts GeoIp.getcountryandorg(ip)

puts OpenSSL::SSL::SSLContext::DEFAULT_PARAMS
puts
puts OpenSSL::SSL::SSLContext::METHODS