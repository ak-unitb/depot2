json.array!(@stock_exchange_daily_closing_prices) do |stock_exchange_daily_closing_price|
  json.extract! stock_exchange_daily_closing_price, :id, :stock_exchange, :price, :date_of_day
  json.url stock_exchange_daily_closing_price_url(stock_exchange_daily_closing_price, format: :json)
end
