
require "net/https"
require "uri"

secret = '6Ld4c6IUAAAAABrp6qSbOeB3wo-pD1XpB90QyJc3'
response = '03AOLTBLSBBb8Vc_-3eQntxS-m9Fb3GspYRTVPUjm5t0fYLMBVVeabVLDxBG_9znYB2XJbJqivZrnpBzQS2dRL0aNJ16XLxDurN8q-dXJWTJrEdzrkd1eEJVyTciwStZG4AW1UsE3kFk6EBCh0Wg28ZL59h79cQdHsq9o6QtREU0oqZulplVxfPHTdXv0xsFVX8A2Ynm67iLXjQsyLgzkEqT4NM1gCz1otyNX1EluMHn18kQyLiZtZCkgUBJ8r1X0-4ZzFJ_7QtRU6tlw8O7K6Lr3iBaSCw1MJt5pzrVJNKO1LcYnm-r1J0jCCMNiqJ7kWTVkabI7UzxHW'

uri = URI.parse("https://www.google.com/recaptcha/api/siteverify?secret=#{secret}&response=#{response}")
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

request = Net::HTTP::Get.new(uri.request_uri)

response = http.request(request)
puts response.body



#uri = URI("https://www.google.com/recaptcha/api/siteverify")
#https = Net::HTTP.new(uri.host, uri.port)
#https.use_ssl = true#

#response = https.get_response('/')
#p response.body

#response = Net::HTTP.get_response('example.com', '/')

#verify_request = Net::HTTP::Post.new(uri.path, {'Content-Type' =>'application/json'})

#verify_request["secret"] = '6Ld4c6IUAAAAABrp6qSbOeB3wo-pD1XpB90QyJc3'
#verify_request["response"] = '03AOLTBLQ3zSMJQh3fKhACyMIVNXXaGW6fGXfpZE0zT_o66zGkFobGPfnXE_mvxjQZX1Ki1ArflqI7LMBVIi7GgMKnPRfUM1_BlUqHqSFkp_v9HOhuQu7hRUUrfebfqKOC1ybCUJOFIAx8MvbZ2ooBqtJ5sXYC5I_kg9PRq7gsxy2'
#verify_request["remoteip"] = 'nil'

#request_json = {secret: '6Ld4c6IUAAAAABrp6qSbOeB3wo-pD1XpB90QyJc3',
#                response: '' }

#p request_json
#p request_json.to_json
#verify_request.body = request_json.to_json
#p verify_request
#p verify_request.body
#response = https.request(verify_request)
#p response.body

#response.each_header { |h| puts h + ' ' + response[h] } 


