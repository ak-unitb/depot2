json.array!(@shares) do |share|
  json.extract! share, :id, :isin, :name, :currency, :stock_exchange_id
  json.url share_url(share, format: :json)
end
