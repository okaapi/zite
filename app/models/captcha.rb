
require 'net/http'
require 'json'
class Captcha

  def self.verify(token)
  
      secret = Rails.configuration.captcha_secret 

      uri = URI.parse("https://www.google.com/recaptcha/api/siteverify?secret=#{secret}&response=#{token}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
	  http.read_timeout = 1  # set this to zero to check time out... or 'http://httpstat.us/200?sleep=3000'
      http.open_timeout = 1

      request = Net::HTTP::Get.new(uri.request_uri)

      response = http.request(request)
      json_response = JSON.parse(response.body)
	  
      return json_response["score"]
	  
  end
  

end
