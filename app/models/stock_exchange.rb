class StockExchange < ActiveRecord::Base
  has_many :shares
  has_many :stock_exchange_daily_closing_prices
  
  has_one :last_daily_closing_price, -> { order('stock_exchange_daily_closing_prices.date_of_day DESC') }, class_name: 'StockExchangeDailyClosingPrice'

  def stock_exchange_daily_closing_prices_from(date)
    stock_exchange_daily_closing_prices.find_all{ |p| p.date_of_day >= date }
  end

  def self.sorted_by_name
    StockExchange.all.sort_by(&:name)
  end

end
