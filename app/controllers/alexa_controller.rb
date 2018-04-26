class AlexaController < ApplicationController

  def beckman
    logger.info( '**** BECKMAN')
    logger.info( '*')
    logger.info( YAML::dump(params) )

#    case params['request']['type']
#    when 'LaunchRequest'
#      response = LaunchRequest.new.respond
#    when 'IntentRequest'
#      response = IntentRequest.new.respond(params['request']['intent'])
#    end
#    render json: response
    
    render json: params
    
    logger.info( '*')
    logger.info( '**** END')

  end

=begin
  def respond intent_request
    intent_name = intent_request['name']

    Rails.logger.debug { "IntentRequest: #{intent_request.to_json}" }

    case intent_name
    when 'Overview'
      speech = 'Here is the overview!'
    when 'TurnAroundTime'
      speech = 'Showing turn around time.'
    when 'Throughput'
      speech = 'Showing turn throughput.'
    when 'AMAZON.StopIntent'
      speech = 'Beckman, out.'
    else
              speech = 'I do not know what that is.'
    end

    output = AlexaRubykit::Response.new
    output.add_speech(speech)
    output.build_response(true)
  
  end
=end
  
end
