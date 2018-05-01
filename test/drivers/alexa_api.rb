
require "../../config/environment" unless defined?(::Rails.root)

require 'net/http'
require 'json'


json = { version: "1.0",
         request: {
           type: "LaunchRequest"
         }
       }

  uri = URI('https://api.amazonalexa.com/v2/householdlists') 
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  ...some use apiAccessToken....
  req = Net::HTTP::Get.new(uri.path, 'Content-Type' => 'application/json')
  res = http.request(req)

   #req.body = json.to_json

  puts "RESPONSE #{res.body}"  
