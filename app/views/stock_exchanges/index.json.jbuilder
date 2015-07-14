json.array!(@stock_exchanges) do |stock_exchange|
  json.extract! stock_exchange, :id, :name, :closing_time, :timezone, :location
  json.url stock_exchange_url(stock_exchange, format: :json)
end
