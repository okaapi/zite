
class GeoIp

  def self.getcountryandorg(ip)
  
      if !ip
	    return ''
	  end
  
      url = "http://ip-api.com/json/#{ip}"

      json_response = HttpsRequest.json(url)
	  if json_response["country"] and json_response["org"]
	    return json_response["country"] + ' ' + json_response["org"]
      else
	    return ''
	  end
	  
  end
  
end
