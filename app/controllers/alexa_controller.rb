

class AlexaController < ApplicationController

  skip_before_action :verify_authenticity_token
  
  def index

    if params['request']     
      case params['request']['type']
      when 'LaunchRequest'
        response = launch_request_response("Welcome to the Beckman dashboard!")
      when 'IntentRequest'
        response = intent_request_response_beckman(params['request']['intent'])
      else
        response = {request: params['request']['type'],status: 'error request'}.to_json
      end
    else
      response = {request: params,status: 'error params'}.to_json
    end

    render json: response
    
  end

  def shopping

    (1..10).each {|x| logger.info('*')}
    logger.info( params )
    (1..10).each {|x| logger.info('*')}
    logger.info( params['request'] )
    (1..10).each {|x| logger.info('*')}

    if params['request']     
      case params['request']['type']
      when 'LaunchRequest'
        response = launch_request_response("Welcome to the  Blackberry Hill List!")
      when 'IntentRequest'
        response = intent_request_response_shopping(params['request']['intent'])
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

  def launch_request_response(speech)
    { version: "1.0",
      response: {
        outputSpeech: {
          type: "PlainText",
          text: speech },
        shouldEndSession: "false" }
    }        
  end

  def intent_request_response_beckman( intent )
      intent_name = intent['name']
      stop_interaction = false
      case intent_name
      when 'Overview'
        Alexa.create(intent: intent_name)
        speech = 'Here is the overview. You can ask to show turnaround time or sample volume, or to cancel.'
      when 'Turnaround'
        Alexa.create(intent: intent_name)
        speech = 'This shows turnaround time. Current turnaround time is 40 minutes.'
      when 'Samplevolume'
        Alexa.create(intent: intent_name)
        speech = 'This shows sample volume or throughput.'
      when 'AMAZON.HelpIntent'
        speech = 'You can say show overview, turnaroundtime, or sample volume.'
      when 'AMAZON.StopIntent'
        speech = 'Beckman dashboard, out.'
        stop_interaction = true
      when 'AMAZON.CancelIntent'
        speech = 'Beckman dashboard, out.'
        stop_interaction = true
      else
        speech = 'I did not understand that.'
      end

      output = AlexaRubykit::Response.new
      output.add_speech(speech)
      output.build_response(stop_interaction)
  end

  def intent_request_response_shopping( intent )
      intent_name = intent['name']
      intent_confirmed = intent['confirmationStatus']
      logger.info( intent_name )
      logger.info( intent_confirmed )
      
      stop_interaction = false
      confirm_clear = false
      case intent_name
      when 'add'
        if ( item = intent['slots']['Items']['value'] )
          logger.info( item )
          p = Page.get_latest('blackberry_hill' )
          p.content = p.content + '<br>'+ item
          p.save
          speech = 'Adding ' + item + ' to the Blackberry Hill List'          
          p.uncache( SiteMap.by_internal( p.site )  )
        else
          speech = 'Sorry, that did not work.'
        end          
      when 'list'
        p = Page.get_latest('blackberry_hill' )
        sp = p.speech
        if sp == ''
          speech = 'The Blackberry List is empty'
        else
          speech = 'Here is what is on the Blackberry Hill List : ' + sp
        end
      when 'clear'
        if intent_confirmed == 'CONFIRMED'
          p = Page.get_latest('blackberry_hill' )
          p.content = ''
          p.save
          speech = 'Clearing Blackberry Hill List'
          p.uncache( SiteMap.by_internal( p.site )  )
        elsif intent_confirmed == 'DENIED'
          speech = 'Ok, I will not touch the list'
        else
          confirm_clear = true
        end
      when 'AMAZON.HelpIntent'
        speech = 'You can add items, like: add eggs, and you can use list and clear as commands'
      when 'AMAZON.StopIntent'
        speech = 'Blackberry Hill List, out.'
        stop_interaction = true
      when 'AMAZON.CancelIntent'
        speech = 'Blackberry Hill List, out.'
        stop_interaction = true
      else
        speech = 'I did not understand that.'
      end

      if !confirm_clear
        { version: "1.0",
          response: {
            outputSpeech: {
              type: "PlainText",
              text: speech },
            shouldEndSession: stop_interaction ? "true" : "false" }
        }        
      else
        { version: "1.0",
          response: {
            directives: [
              {
                type: "Dialog.Delegate",
                updatedIntent: {
                  name: "clear",
                  slots: {}
                }
              }
            ],
            shouldEndSession: stop_interaction ? "true" : "false" }
        }        
      end
     
  end
  
end
