require 'net/http'
require 'json'

class HttpRequest

  def self.json(url)
  
      begin  
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.read_timeout = 1  # set this to zero to check time out... or 'http://httpstat.us/200?sleep=3000'
        http.open_timeout = 1
        response = http.start() {|http| http.get(url) }
        json_response = JSON.parse(response.body) 
        return json_response
      rescue Exception => e
        return {"exception" => e}
      end
	  
  end
  
end
