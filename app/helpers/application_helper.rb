module ApplicationHelper
  def js?
    Rails.configuration.use_javascript
  end
  def prettytime( t )
    t.getlocal.strftime("%H:%M %m-%d-%Y")
  end
end
