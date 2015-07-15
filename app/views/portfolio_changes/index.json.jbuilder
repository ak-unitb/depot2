json.array!(@portfolio_changes) do |portfolio_change|
  json.extract! portfolio_change, :id, :share, :transaction_type, :quantity, :price_per_share, :total_cost_of_order, :date_of_day
  json.url portfolio_change_url(portfolio_change, format: :json)
end
