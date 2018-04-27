class AlexaController < ApplicationController

  skip_before_action :verify_authenticity_token #, if: :json_request?  
  
  def index

    if params['request']
      logger.info( '* request type')
      logger.info( params['request']['type'])
      
      case params['request']['type']
      when 'LaunchRequest'
        response = launch_request_response
      when 'IntentRequest'
        logger.info( params['request']['intent']['name'])
        response = intent_request_response(params['request']['intent']['name'])
      else
        response = {request: params['request']['type'],status: 'error request'}.to_json
      end
    else
      response = {request: params,status: 'error params'}.to_json
    end

    render json: response
    
  end
  
  def dashboard
    @intent = Alexa.last.intent       
    session[:last_intent] = @intent   
    render layout: 'dashboard'  
  end
  
  def dashboard_partial
    @intent = Alexa.last.intent       
    session[:last_intent] = @intent
    render partial: 'dashboard'        
  end  
    
  
private

  def launch_request_response
    output = AlexaRubykit::Response.new
    output.add_speech("Welcome to the Beckman dashboard!")
    output.build_response(false)
  end

  def intent_request_response( intent_name )
      logger.info( intent_name )
      case intent_name
      when 'Overview'
        Alexa.create(intent: intent_name)
        speech = 'Here is the overview.'
      when 'Turnaroundtime'
        Alexa.create(intent: intent_name)
        speech = 'This shows turnaround time.'
      when 'Samplevolume'
        Alexa.create(intent: intent_name)
        speech = 'This shows sample volume or throughput.'
      when 'AMAZON.HelpIntent'
        speech = 'You can say show overview, turnaroundtime, or sample volume.'
      when 'AMAZON.StopIntent'
        speech = 'Beckman dashboard, out.'
      else
        speech = 'I am going to ignore that.'
      end

      output = AlexaRubykit::Response.new
      output.add_speech(speech)
      output.build_response(false)
  end
  
end
