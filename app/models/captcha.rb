
require 'net/http'
require 'json'
class Captcha

  def self.verify(token)

      if token == Rails.configuration.captcha_good_test_token
	    return 0.9
      elsif token == Rails.configuration.captcha_bad_test_token
	    return 0.1
      end
	  
      secret = Rails.configuration.captcha_secret 

      uri = URI.parse("https://www.google.com/recaptcha/api/siteverify?secret=#{secret}&response=#{token}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
	  http.read_timeout = 1  # set this to zero to check time out... or 'http://httpstat.us/200?sleep=3000'
      http.open_timeout = 1
      request = Net::HTTP::Get.new(uri.request_uri)

      begin  
        response = http.request(request)
        json_response = JSON.parse(response.body) 
        return  json_response["score"]	
      rescue Exception => e
        return -1.0
	  end

	  
  end
  

end
