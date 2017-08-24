module ApplicationHelper
  def prettytime( t )
    if t
      t.getlocal.strftime("%H:%M %m-%d-%Y")
    else
      'sometime'
    end
  end
  def is_editor?
    @current_user and @current_user.editor? 
  end  
  def is_user?
    @current_user and @current_user.user? 
  end
  def is_admin?
    @current_user and @current_user.admin?   
  end  
  def fb_app_id?
    Rails.configuration.fb_app_id
  end
  
end
