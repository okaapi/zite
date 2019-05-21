
class Captcha

  def self.verify(token)

      if token == Rails.configuration.captcha_good_test_token
	    return 0.9
      elsif token == Rails.configuration.captcha_bad_test_token
	    return 0.1
      end
	  
      secret = Rails.configuration.captcha_secret 
	  url = "https://www.google.com/recaptcha/api/siteverify?secret=#{secret}&response=#{token}"

      json_response = HttpsRequest.json(url)
	  if json_response["score"]
	    return json_response["score"].to_f
      else
	    return -1.0
	  end
	  
  end
  

end
