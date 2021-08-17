
class GeoIp

  def self.getcountryandorg(ip)
  
      if !ip
        return 'Geo: no ip'
      end
      
      url = "http://ip-api.com/json/#{ip}"

      json_response = HttpRequest.json(url)
      if json_response["country"] and json_response["org"]
        geoip = json_response["country"] + ' ' + json_response["org"]
      else
        geoip = nil
      end

      return geoip
      
  end
  
end
