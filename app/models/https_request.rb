require 'net/http'
require 'json'

class HttpsRequest

  def self.json(url)
  
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
	  http.read_timeout = 1  # set this to zero to check time out... or 'http://httpstat.us/200?sleep=3000'
      http.open_timeout = 1
	  
      begin  
	  response = http.start() {|http| http.get(url) }
        json_response = JSON.parse(response.body) 
        return json_response
      rescue Exception => e
        return {"exception" => e}
      end
	  
  end
  
end
