json.array!(@identifiers) do |identifier|
  json.extract! identifier, :id, :share_id, :name, :provider
  json.url identifier_url(identifier, format: :json)
end
