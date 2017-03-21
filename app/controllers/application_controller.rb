
class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception
  before_action :set_current_user_session_and_create_action
   	
  def only_if_admin
    unless @current_user and @current_user.role == "admin"
      redirect_to '/', notice: "must be admin"
    end
  end
  
  private
  
  def set_current_user_session_and_create_action
       
      #
      # set the site name - this is like a global variable, it will be used
      # in each model (via ZiteActiveRecord)
      #  
      if ( host = SiteMap.where( external: request.host ).take )
        ZiteActiveRecord.site( host.internal )
      else 
        ZiteActiveRecord.site( request.host )
      end
         	  
      #
      #  set the current user session
      #
	  @current_user_session = UserSession.recover( session[:user_session_id] )
	  if @current_user_session
	    #nothing !
	  elsif !@current_user_session
	    @current_user_session = UserSession.new_ip_and_client( nil, request.remote_ip(),
	                                                               request.env['HTTP_USER_AGENT'])
	    session[:user_session_id] = @current_user_session.id 
	  end 
  	  
  	  #
	  if @current_user_session.site != ZiteActiveRecord.site? 
	    reset_session
	    redirect_to '/', alert: "name mismatch #{@current_user_session.site} #{request.host}"
	  end

	  #
	  #  current user (this is just a shorthand for @current_user_session._user throughout)
	  #
	  @current_user = User.by_id( @current_user_session.user_id )
	  if @current_user  and
	       @current_user.site != @current_user_session.site
        reset_session
	    redirect_to '/', 
		    alert: "site mismatch #{@current_user_session.user.site} #{@current_user_session.site}"
      end
	  
	  #
	  #  log the action
	  #  
      UserAction.add_action( @current_user_session.id, controller_name, action_name, params )            


  end
     
end
