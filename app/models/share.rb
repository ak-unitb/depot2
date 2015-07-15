class Share < ActiveRecord::Base
  belongs_to :stock_exchange

  has_many :daily_closing_prices
  has_many :identifiers
  has_many :portfolio_changes

  has_one :last_daily_closing_price, -> { order('daily_closing_prices.date_of_day DESC') }, class_name: 'DailyClosingPrice'
  has_one :max_daily_closing_price, -> { order('daily_closing_prices.price DESC') }, class_name: 'DailyClosingPrice'
  has_one :min_daily_closing_price, -> { order('daily_closing_prices.price ASC') }, class_name: 'DailyClosingPrice'

  def name_isin
    return "".concat(name.to_s).concat(" (").concat(isin.to_s).concat(")")
  end

  def self.sorted_by_name_isin
    Share.all.sort_by(&:name_isin)
  end

  def portfolio_sums
    portfolio_sums_by_date( Time.now )
  end

  def portfolio_sums_by_date( time )
    # SELECT
    #     `share_id`,
    #     SUM(`quantity`) as `total_quatity`,
    #     SUM(`price_per_share`*`quantity`)/SUM(`quantity`) as `average_price_per_share`,
    #     SUM(`total_cost_of_order`)  as `total_cost_of_orders`
    # FROM `portfolio_changes`
    # WHERE `date_of_day` <= <time>
    # GROUP BY share_id
    @portfolio_sums = {
      :total_quantity => 0,
      :average_price => 0,
      :total_price => 0,
      :total_cost_of_orders => 0
    }
    portfolio_changes.each { |pc|
      if pc.date_of_day <= time.to_date
        @portfolio_sums[:total_quantity] += pc.quantity
        @portfolio_sums[:total_price] += pc.price_per_share * pc.quantity
        @portfolio_sums[:total_cost_of_orders] += pc.total_cost_of_order
      end
    }
    if @portfolio_sums[:total_quantity] > 0
      @portfolio_sums[:average_price] = @portfolio_sums[:total_price] / @portfolio_sums[:total_quantity]
    else
      @portfolio_sums[:average_price] = 0
    end
    @portfolio_sums
  end


  def historical_prices
      _historical_prices_from(DateTime.new.to_date)
  end

  def historical_prices_from(date)
    _historical_prices_from(date)
  end

  def last_closing_price
    last_daily_closing_price
  end
  
  def max_daily_closing_price_since(date)
    daily_closing_prices.where("`daily_closing_prices`.`date_of_day` > '"+date.to_s+"'").order("price DESC").first
  end

  def min_daily_closing_price_since(date)
    daily_closing_prices.where("`daily_closing_prices`.`date_of_day` > '"+date.to_s+"'").order("price ASC").first
  end

  def relation_current_value_to_costs_in_percent
    if !last_closing_price.nil? then
      last_closing_price.price / (portfolio_sums[:average_price] / 100)
    else
      0
    end
  end

  def last_total_value
    if !last_closing_price.nil? then
      portfolio_sums[:total_quantity] * last_closing_price.price
    else
      0
    end
  end

  def previous_total_value
    if !last_closing_price.nil? && !last_closing_price.previous.nil? then
      portfolio_sums[:total_quantity] * last_closing_price.previous.price
    else
      0
    end
  end

  def profit_or_lost_by_current_share_price
    last_total_value - portfolio_sums[:total_price]
  end

  def profit_or_lost_by_total_costs
    last_total_value + portfolio_sums[:total_cost_of_orders]
  end

  def notional_buy
    #NotionalBuy.new( self, total_price_normalised_to_500_tranches )
    #notional_buy_by_quantity( total_price_normalised_to_500_tranches )
    notional_buy_by_investment_of( total_price_normalised_to_500_tranches )
  end

  def notional_buy_by_investment_of( investment = 0 )
    return NotionalBuy.new( self, investment.to_i, nil )
  end

  def notional_buy_by_quantity( quantity = 0 )
    NotionalBuy.new( self, (quantity.to_i * last_closing_price.price).ceil, nil )
  end
  
  def notional_buy_by_price( investment = 0, quantity = 0, price = 0.0 )
    if investment.nil? || investment == 0
      puts "calculating by quantity"
      puts price.to_f
      NotionalBuy.new( self, (quantity.to_i * price.to_f), price.to_f )
    else
      puts "calculating by investment"
      puts price.to_f
      NotionalBuy.new( self, investment.to_i, price.to_f )
    end
  end

  ### Notional buy:
  class NotionalBuy

    @share = nil
    @total_price_of_investment = nil
    @share_price_for_investment = nil
    # @quantity = nil
    # @total_price = nil
    # @price_per_share = nil
    # @change_of_average_price_in_currency = nil
    # @change_of_average_price_in_percent = nil
    # @quantity_after = nil
    # @total_value_after = nil
    # @difference_of_total_price_to_total_value = nil

    

    def initialize( share, total_price_of_investment, share_price_for_investment )
      @share = share
      @total_price_of_investment = total_price_of_investment.to_i
      if share_price_for_investment.nil? && !@share.last_closing_price.nil?
        @share_price_for_investment = @share.last_closing_price.price
      else
        @share_price_for_investment = share_price_for_investment.to_f
      end
      
      #puts "###"
      #puts self.inspect
      #puts "###"
      
      # @quantity = quantity
      # @total_price = total_price
      # @price_per_share = price_per_share
      # @change_of_average_price_in_currency = change_of_average_price_in_currency
      # @change_of_average_price_in_percent = change_of_average_price_in_percent
      # @quantity_after = quantity_after
      # @total_value_after = total_value_after
      # @difference_of_total_price_to_total_value = difference_of_total_price_to_total_value
    end

    def share
      @share
    end
    
    def share_price_for_investment
      @share_price_for_investment.to_f
    end

    def total_price_of_investment
      @total_price_of_investment
    end

    def quantity
      if @share_price_for_investment != 0 then
        @quantity = ( @total_price_of_investment / @share_price_for_investment ).floor.to_i
      else
        @quantity = 0
      end
    end
  
    def total_price
      @total_price = @share_price_for_investment * quantity
    end 
  
    def price_per_share
      if ( quantity + @share.portfolio_sums[:total_quantity] ) != 0
        @price_per_share = ( quantity * @share_price_for_investment + @share.portfolio_sums[:total_quantity] * @share.portfolio_sums[:average_price] ) / ( quantity + @share.portfolio_sums[:total_quantity] )
      else
        0
      end
    end
  
    def change_of_average_price_in_currency
      @change_of_average_price_in_currency = price_per_share - @share.portfolio_sums[:average_price]
    end
  
    def change_of_average_price_in_percent
      if @share.portfolio_sums[:average_price] != 0 then
        @change_of_average_price_in_percent = price_per_share / ( @share.portfolio_sums[:average_price] / 100 ) - 100
      else
        0
      end
    end
    
    def quantity_after
      @quantity_after = ( quantity + @share.portfolio_sums[:total_quantity] ).to_i
    end
  
    def total_value_after
      @total_value_after = quantity_after * @share_price_for_investment
    end
  
    def difference_of_total_price_to_total_value
      @difference_of_total_price_to_total_value = total_value_after - ( @share.portfolio_sums[:total_price] + total_price )
    end

  end
  ### /Notional buy

  private
    def total_price_normalised_to_500_tranches
      (portfolio_sums[:total_price] / 500).ceil * 500
    end

    def _historical_prices_from(date)
      @historical_prices = []
      # logger.debug "dailyClosingPrice hash: #{d.inspect}" || 
      daily_closing_prices.find_all{ |d| d.date_of_day >= date }.sort_by { |sds| sds.date_of_day }.each { |dcp|
        historic_portfolio_sum = portfolio_sums_by_date( dcp.date_of_day )
        @historical_prices.push(
          {
            :date_of_day => dcp.date_of_day,
            :total_market_value => historic_portfolio_sum[:total_quantity] * dcp.price,
            :total_win => (historic_portfolio_sum[:total_quantity] * dcp.price) - (historic_portfolio_sum[:total_quantity] * historic_portfolio_sum[:average_price]),
            :total_price => historic_portfolio_sum[:total_price]
          }
        )
      }
      @historical_prices
    end

end
