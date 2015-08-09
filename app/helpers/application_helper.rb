module ApplicationHelper
  def js?
    Rails.configuration.use_javascript
  end
  def prettytime( t )
    if t
      t.getlocal.strftime("%H:%M %m-%d-%Y")
    else
      'sometime'
    end
  end
end
