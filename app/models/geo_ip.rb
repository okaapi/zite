require 'net/http'
require 'json'

class GeoIp

  def self.getgeo(ip)
  
      uri = URI.parse("http://ip-api.com/json/#{ip}")
      http = Net::HTTP.new(uri.host, uri.port)
      #http.use_ssl = true
      #http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Get.new(uri.request_uri)

      response = http.request(request)
      json_response = JSON.parse(response.body)
	  
      return json_response["country"]
	  
  end
  

end
