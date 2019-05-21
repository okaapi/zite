
class FbLogin

  def self.check_token(token)
  
      url = 'https://graph.facebook.com/me?fields=name,email&access_token=' + token
      
      json_response = HttpsRequest.json(url)

      return json_response
	  
  end
  

end
