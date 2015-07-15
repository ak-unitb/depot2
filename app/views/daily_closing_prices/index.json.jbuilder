json.array!(@daily_closing_prices) do |daily_closing_price|
  json.extract! daily_closing_price, :id, :share, :price, :date_of_day
  json.url daily_closing_price_url(daily_closing_price, format: :json)
end
