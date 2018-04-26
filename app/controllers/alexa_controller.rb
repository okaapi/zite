class AlexaController < ApplicationController

  def beckman
    logger.info( '**** BECKMAN')
    logger.info( YAML::dump(params) )
    logger.info( '**** END')
    
    render json: params
    
  end

end
