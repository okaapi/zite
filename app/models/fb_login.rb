
class FbLogin

  def self.check_token(token)
  
      url = URI.parse('https://graph.facebook.com/me?fields=name,email&access_token=' + token )
      
      json_response = HttpsRequest.json(url)
	  
      return JSON.parse(resp.body)
	  
  end
  

end