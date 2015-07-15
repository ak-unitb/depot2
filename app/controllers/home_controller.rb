class HomeController < ApplicationController

  def index
    @shares = Share.order( :name, :isin ).all #( :include => :daily_closing_prices )
    @shares_size = @shares.size
    # take the last 30 from each share (date_of_day DESC)
    @daily_closing_prices_overview = DailyClosingPrice.find_by_sql [
        "SELECT * FROM (SELECT s.name, s.isin, s.currency, d.id, d.share_id, d.price, d.date_of_day
         FROM shares s JOIN daily_closing_prices d ON s.id = d.share_id) as tbl
         ORDER BY tbl.date_of_day DESC, tbl.name ASC, tbl.isin ASC LIMIT 0, ?", 30 * @shares_size ]
    # reverse date order to ASC
    @daily_closing_prices_overview = @daily_closing_prices_overview.sort_by { |dc| dc.date_of_day }
    @sums_of_share_values = sums_of_share_values
    # SELECT * FROM
    #   (SELECT s.id, s.name, s.isin, s.currency, d.share_id, d.price, d.date_of_day FROM shares s JOIN daily_closing_prices d ON s.id = d.share_id) as tbl
    # ORDER BY tbl.date_of_day, tbl.name, tbl.isin;
  end

  def calculate_notional_buy
    if params[ :mode ] == "by_quantity"
      #@share = Share.find( params[ :share_id ] )
      @share = @shares.select { |share| share.id == params[ :share_id ] }
      @notional_buy = @share.notional_buy_by_quantity( params[ :quantity ] )
    elsif params[ :mode ] == "by_investment_of"
      #@share = Share.find( params[ :share_id ] )
      @share = @shares.select { |share| share.id == params[ :share_id ] }
      @notional_buy = @share.notional_buy_by_investment_of( params[ :investment ] )
    else
      # case: error!!!!      
    end
    respond_to do |format|
      format.html # calculate_notional_buy.html.erb
      format.json { render json: @notional_buy }
    end
  end

  def charts_datas
    collect_charts_datas(1)
    respond_to do |format|
      format.html
      format.json
    end
  end

  def charts_datas_comparable
    collect_charts_datas(1)
    respond_to do |format|
      format.json
      format.text
    end
  end

  def charts_datas_normalized
    stock_prices = stock_exchange_normalized_prices(1)
    @portfolio_changes = PortfolioChange.all.sort { |pc1,pc2| pc1.date_of_day <=> pc2.date_of_day }
    depot_total_values_per_date = depot_total_performance(@portfolio_changes.first[:date_of_day])
    @depot_perfomance_per_date = []
    @differences = []
    @total_performances = {}
    depot_total_values_per_date.keys.sort.each { |timestamp|
      value_per_date = depot_total_values_per_date[timestamp]
      total_perfomance = (value_per_date[:accumulated_market_value] / (value_per_date[:accumulated_price] / 100)).to_f - 100
      @total_performances[timestamp] = total_perfomance
      @depot_perfomance_per_date.push(
        [timestamp, total_perfomance]
      )
    }
    stock_prices.each { |stock_price|
      if @total_performances[stock_price[:date_of_day]] != nil
        @differences.push(
          [stock_price[:date_of_day], (@total_performances[stock_price[:date_of_day]] - stock_price[:percentaged])]
        )
      end
    }
    respond_to do |format|
      format.json
      format.text { render :json => { 
          :depot_perfomance_per_date => @depot_perfomance_per_date,
          #:stock_prices => stock_prices,
          :differnces => @differences
        }
      }
      format.html
    end
  end

  # get /home/todays_report
  def todays_report
    @shares = Share::sorted_by_name_isin
    @stock_exchanges = StockExchange::sorted_by_name
    _sums_of_share_values = sums_of_share_values
    @depot_values = {
      :name => "Depot",
      :current_value => _sums_of_share_values[:last_total_value],
      :previous_value => _sums_of_share_values[:previous_total_value],
      :change_percent => (_sums_of_share_values[:last_total_value] - sums_of_share_values[:previous_total_value]) / (_sums_of_share_values[:previous_total_value] / 100 ),
      :change_absolute => _sums_of_share_values[:last_total_value] - sums_of_share_values[:previous_total_value],
      :profit_or_lost => _sums_of_share_values[:profit_or_lost_by_total_costs]
    }
    @average_yearly_interest = average_yearly_interest
    
    respond_to do |format|
      format.json { render :json => @depot_values }
      format.html { render :layout => false }
    end
  end

  private
    def sums_of_share_values
      # Gesamter Einstiegswert, Kaufpreis inkl. Ausgabe-Aufschlag, Aktueller Gesamtwert, CashFlow Kurs, Gesamter CashFlow
      sums_of_share_values = {
        :total_price => 0,
        :total_cost_of_orders => 0,
        :last_total_value => 0,
        :previous_total_value => 0,
        :profit_or_lost_by_current_share_price => 0,
        :profit_or_lost_by_total_costs => 0,
        :costs_of_taxes_absolute => 0,
        :costs_of_taxes_in_percent => 0,
        :profit_or_lost_by_current_share_price_in_percent => 0,
        :profit_or_lost_by_total_costs_in_percent => 0
      }
      @shares.each { |share|
        sums_of_share_values[:total_price] += share.portfolio_sums[:total_price]
        sums_of_share_values[:total_cost_of_orders] += share.portfolio_sums[:total_cost_of_orders]
        sums_of_share_values[:last_total_value] += share.last_total_value
        sums_of_share_values[:previous_total_value] += share.previous_total_value
        sums_of_share_values[:profit_or_lost_by_current_share_price] += share.profit_or_lost_by_current_share_price
        sums_of_share_values[:profit_or_lost_by_total_costs] += share.profit_or_lost_by_total_costs
      }
      if @shares.count > 0
        sums_of_share_values[:costs_of_taxes_absolute] = sums_of_share_values[:total_price] + sums_of_share_values[:total_cost_of_orders]
        sums_of_share_values[:costs_of_taxes_in_percent] = ( - sums_of_share_values[:total_cost_of_orders] / ( sums_of_share_values[:total_price] / 100 ) ) - 100
        sums_of_share_values[:profit_or_lost_by_current_share_price_in_percent] = sums_of_share_values[:last_total_value] / ( sums_of_share_values[:total_price] / 100 ) - 100 
        sums_of_share_values[:profit_or_lost_by_total_costs_in_percent] = sums_of_share_values[:last_total_value] / ( - sums_of_share_values[:total_cost_of_orders] / 100 ) - 100 
      end
      sums_of_share_values
    end

    def collect_charts_datas(stock_exchange_id)
      @stock_exchange = StockExchange.find(stock_exchange_id)
      @portfolio_changes = PortfolioChange.all.sort { |pc1,pc2| pc1.date_of_day <=> pc2.date_of_day }
      @stock_exchange_daily_closing_prices = @stock_exchange.stock_exchange_daily_closing_prices_from(@portfolio_changes.first[:date_of_day]).sort!{ |d1,d2| d1.date_of_day <=> d2.date_of_day }
      @depot_total_values = depot_total_values(@portfolio_changes.first[:date_of_day])
    end

    def depot_total_values(from)
      values = {}
      @shares = Share.order( :name, :isin ).all
      @shares.each { |s|
        s.historical_prices_from(from).each { |hp|
          key = hp[:date_of_day].to_time.utc.to_i * 1000
          if values[key] != nil
            values[key] += hp[:total_market_value].to_f
          else
            values[key] = hp[:total_market_value].to_f
          end
        }
      }
      values
    end

    def depot_total_performance(from)
      values = {}
      @shares = Share.order( :name, :isin ).all
      @shares.each { |s|
        #if s.name != "E.ON"
          s.historical_prices_from(from).each { |hp|
            key = hp[:date_of_day].to_time.utc.to_i * 1000
            if values[key] != nil
              values[key][:accumulated_market_value] += hp[:total_market_value].to_f
              values[key][:accumulated_price] += hp[:total_price].to_f
            else
              values[key] = {
                :historic_price => hp,
                :accumulated_market_value => hp[:total_market_value].to_f,
                :accumulated_price => hp[:total_price].to_f
              }
            end
          }
        #end
      }
      values
    end

    def stock_exchange_normalized_prices(stock_exchange_id)
      @stock_exchange = StockExchange.find(stock_exchange_id)
      @portfolio_changes = PortfolioChange.all.sort { |pc1,pc2| pc1.date_of_day <=> pc2.date_of_day }
      stock_exchange_prices = @stock_exchange.stock_exchange_daily_closing_prices_from(@portfolio_changes.first[:date_of_day]).sort!{ |d1,d2| d1.date_of_day <=> d2.date_of_day }
      stock_exchange_first_price = stock_exchange_prices.first[:price]
      @stock_exchange_normalized_prices = []
      stock_exchange_prices.each { |price|
        timestamp = price[:date_of_day].to_time.utc.to_i * 1000
        # stock_exchange_first_price => 100%
        # price @ date => how many percent of stock_exchange_first_price
        @stock_exchange_normalized_prices.push(
          {
            :date_of_day => timestamp,
            :readable_date => price[:date_of_day].to_s,
            :percentaged => (price[:price] / (stock_exchange_first_price / 100)).to_f - 100,
            :absolute => price[:price],
            :point_zero_value => stock_exchange_first_price
          }
        )
      }
      @stock_exchange_normalized_prices
    end

    def average_yearly_interest
      depotStart = PortfolioChange.where("transaction_type = 'buy'").order("`date_of_day` ASC").first.date_of_day
      startCapital = sums_of_share_values[:total_price]
      currentCapital = sums_of_share_values[:last_total_value]

      # formula: http://www.brinkmann-du.de/mathe/gost/p0_zinseszinsrechnung_01.htm
      averageYearlyInterest = 100 * ( ( ( currentCapital / startCapital ).to_f ** ( 1.0 / (DateTime.now.year - depotStart.year).to_f ).to_f ) - 1.0 )
    end

end
