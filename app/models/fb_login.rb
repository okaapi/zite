require 'net/http'
require 'json'

class FbLogin

  def self.check_token(token)
  
      url = URI.parse('https://graph.facebook.com/me?fields=name,email&access_token=' + token )
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true if url.scheme == 'https'
      http.read_timeout = 1  # set this to zero to check time out... or 'http://httpstat.us/200?sleep=3000'
      http.open_timeout = 1
      
      resp = http.start() {|http| http.get(url) }
      
      authentication_logger('   ...done')      
      return JSON.parse(resp.body)
	  
  end
  

end