module ApplicationHelper
  def js?
    Rails.configuration.use_javascript
  end
end
