json.array!(@portfolio_changes) do |portfolio_change|
  json.extract! portfolio_change, :id, :share_id, :transaction_type, :quantity, :price_per_share, :total_cost_of_order, :when
  json.url portfolio_change_url(portfolio_change, format: :json)
end
