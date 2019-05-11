require 'net/http'
require 'json'

class GeoIp

  def self.getcountryandorg(ip)
  
      uri = URI.parse("http://ip-api.com/json/#{ip}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = 1  # set this to zero to check time out... or 'http://httpstat.us/200?sleep=3000'
      http.open_timeout = 1
	  
      request = Net::HTTP::Get.new(uri.request_uri)

      response = http.request(request)
      json_response = JSON.parse(response.body)
	  
	  if json_response["country"] and json_response["org"]
	    return json_response["country"] + ' ' + json_response["org"]
	  else
	    return ''
	  end
	  
  end
  

end
