require 'test_helper'

class RealAlexaUserStoriesTest < ActionDispatch::IntegrationTest 
  
  setup do
    ZiteActiveRecord.site( 'testsite45A67' )
    request
    open_session.host! "testhost45A67"
  end

  test "shopping launch" do
    json = { version: "1.0",
    	     request: {
               type: "LaunchRequest"
             }
           }
    post "/shopping", params: json, as: :json    
    assert_response :success
    r = eval(@response.body)
    assert_equal r[:response][:outputSpeech][:text], 'Welcome to the Blackberry Hill List!'    
    assert_equal r[:response][:shouldEndSession], 'false'         
  end	
  test "shopping list" do
    json = { version: "1.0",
              request: {
                type: "IntentRequest",
                intent: {
                  name: "list",
                  confirmationStatus: "NONE"
                }
              }
            }
    post "/shopping", params: json, as: :json    
    assert_response :success
    r = eval(@response.body)
    assert_equal r[:response][:outputSpeech][:text], 'Here is what is on the Blackberry Hill List : eggs  and avocados'        
    assert_equal r[:response][:shouldEndSession], 'false'              
  end	  
  test "shopping add" do
    json = { version: "1.0",
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
    post "/shopping", params: json, as: :json    
    assert_response :success
    r = eval(@response.body)
    assert_equal r[:response][:outputSpeech][:text], 'Adding carrots to the Blackberry Hill List'   
    assert_equal r[:response][:shouldEndSession], 'false'             
    page = Page.get_latest('blackberry_hill')
    assert_equal page.content, "eggs <br>avocados<br>carrots"
  end
  test "shopping clear" do
    json = { version: "1.0",
              request: {
                type: "IntentRequest",
                intent: {
                  name: "clear",
                  confirmationStatus: "NONE"
                }
              }
            }
    post "/shopping", params: json, as: :json    
    assert_response :success
    r = eval(@response.body)
    assert_equal r[:response][:directives][0][:type], 'Dialog.Delegate'   
    assert_equal r[:response][:directives][0][:updatedIntent][:name], 'clear'   
  end
  test "shopping clear yes" do
    json = { version: "1.0",
                   request: {
                     type: "IntentRequest",
                     intent: {
                       name: "clear",
                       confirmationStatus: "CONFIRMED"
                     }
                   }
                 }
    post "/shopping", params: json, as: :json    
    assert_response :success
    r = eval(@response.body)
    assert_equal r[:response][:outputSpeech][:text], 'Clearing Blackberry Hill List'   
    assert_equal r[:response][:shouldEndSession], 'false'       
  end  
  test "shopping clear no" do
    json = { version: "1.0",
                   request: {
                     type: "IntentRequest",
                     intent: {
                       name: "clear",
                       confirmationStatus: "DENIED"
                     }
                   }
                 }
    post "/shopping", params: json, as: :json    
    assert_response :success
    r = eval(@response.body)
    assert_equal r[:response][:outputSpeech][:text], 'Ok, I will not touch the list'   
    assert_equal r[:response][:shouldEndSession], 'false'       
  end  
  test "shopping cancel" do
    json = { version: "1.0",
                   request: {
                     type: "IntentRequest",
                     intent: {
                       name: "AMAZON.CancelIntent",
                     }
                   }
                 }
    post "/shopping", params: json, as: :json    
    assert_response :success
    r = eval(@response.body)
    assert_equal r[:response][:outputSpeech][:text], 'Blackberry Hill List, out.'   
    assert_equal r[:response][:shouldEndSession], 'true'       
  end    
  test "shopping help" do
    json = { version: "1.0",
                   request: {
                     type: "IntentRequest",
                     intent: {
                       name: "AMAZON.HelpIntent",
                     }
                   }
                 }
    post "/shopping", params: json, as: :json    
    assert_response :success
    r = eval(@response.body)
    assert_equal r[:response][:outputSpeech][:text], 'You can add items, like: add eggs, and you can use list and clear as commands'   
    assert_equal r[:response][:shouldEndSession], 'false'       
  end   
  test "shopping stop" do
    json = { version: "1.0",
                   request: {
                     type: "IntentRequest",
                     intent: {
                       name: "AMAZON.StopIntent",
                     }
                   }
                 }
    post "/shopping", params: json, as: :json    
    assert_response :success
    r = eval(@response.body)
    assert_equal r[:response][:outputSpeech][:text], 'Blackberry Hill List, out.'   
    assert_equal r[:response][:shouldEndSession], 'true'       
  end   
end
