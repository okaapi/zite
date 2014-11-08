json.array!(@pages) do |page|
  json.extract! page, :id, :content, :user_id, :visibility, :editability, :menu, :lock
  json.url page_url(page, format: :json)
end
