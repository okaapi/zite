class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include Auth::CurrentUserSession
  before_action :set_current_user_session_and_create_action
  
  def only_if_admin
    unless current_user_is_admin
      redirect_to '/', notice: "must be admin"
    end
  end   
    
end
