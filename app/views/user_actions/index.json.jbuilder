json.array!(@user_actions) do |user_action|
  json.extract! user_action, :id, :user_session_id, :controller, :action
  json.url user_action_url(user_action, format: :json)
end
