json.array!(@site_maps) do |site_map|
  json.extract! site_map, :id, :external, :internal, :aux
  json.url site_map_url(site_map, format: :json)
end
