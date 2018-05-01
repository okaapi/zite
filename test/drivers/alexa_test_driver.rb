require "../../config/environment" unless defined?(::Rails.root)

require 'net/http'
require 'json'

json_launch = { version: "1.0",
                request: {
                  type: "LaunchRequest"
                }
              }
json_list = { version: "1.0",
              request: {
                type: "IntentRequest",
                intent: {
                  name: "list",
                  confirmationStatus: "NONE"
                }
              }
            }
json_add = { version: "1.0",
              request: {
                type: "IntentRequest",
                intent: {
                  name: "add",
                  confirmationStatus: "NONE",
                  slots: {
                    Items: {
                      name: "Items",
                      value: "carrots"
                    }
                  }                  
                }
              }
            }
                
json_clear = { version: "1.0",
               request: {
                 type: "IntentRequest",
                 intent: {
                   name: "clear",
                   confirmationStatus: "NONE"
                 }
               }
             }
json_clear_yes = { version: "1.0",
                   request: {
                     type: "IntentRequest",
                     intent: {
                       name: "clear",
                       confirmationStatus: "CONFIRMED"
                     }
                   }
                 }
json_clear_no = { version: "1.0",
                   request: {
                     type: "IntentRequest",
                     intent: {
                       name: "clear",
                       confirmationStatus: "DENIED"
                     }
                   }
                 }


while true

  puts "L = launch"
  puts "l = list"
  puts "a = add carrots"
  puts "c = clear"
  puts "y = clear yes"
  puts "n = clear no"
  puts ">>>"
  x = gets

  case x[0]
  when 'L'
    json = json_launch
  when 'l'
    json = json_list
  when 'a'
    json = json_add
  when 'c'
    json = json_clear
  when 'y'
    json = json_clear_yes
  when 'n'
    json = json_clear_no
  else
    json = {nothing: 'when'}
  end
  puts "REQUEST #{json}"
  
  #uri = URI('http://localhost:3000/shopping')
  uri = URI('https://www.menhardt.com/shopping') 
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  req = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
  req.body = json.to_json
  res = http.request(req)

  puts "RESPONSE #{res.body}"  
  puts
  res = eval(res.body)
  if res[:response][:outputSpeech]
    puts res[:response][:outputSpeech][:text]
  elsif res[:response][:directives]
    puts res[:response][:directives][0][:type]
  end
  
  puts 

end
