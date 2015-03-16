class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_current_user_session_and_create_action
   	
  def only_if_admin
    unless @user and @user.role == "admin"
      redirect_to '/', notice: "must be admin"
    end
  end 
 
  private
  
  def set_current_user_session_and_create_action
	  if !( @current_user_session = UserSession.recover( session[:user_session_id] ) )

	    @current_user_session = UserSession.new_ip_and_client( nil, request.remote_ip(),
	                                                               request.env['HTTP_USER_AGENT'])
	    session[:user_session_id] = @current_user_session.id                                                                           
	  end 
	  @user = @current_user_session.user 
      UserAction.add_action( @current_user_session.id, controller_name, action_name, params )            
  end
     
end
