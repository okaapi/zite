
class GeoIp

  def self.getcountryandorg(ip)
  
      if !ip
	    return 'Geo: no ip'
	  end
  
      url = "http://ip-api.com/json/#{ip}"

      json_response = HttpRequest.json(url)
	  if json_response["country"] and json_response["org"]
	    return json_response["country"] + ' ' + json_response["org"]
      else
	    return json_response.to_s
	  end
	  
  end
  
end
