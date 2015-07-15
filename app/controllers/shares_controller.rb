class SharesController < ApplicationController
  before_action :set_share, only: [:show, :edit, :update, :destroy, :charts_data, :charts_historical_data ]

  # GET /shares
  # GET /shares.json
  def index
    @shares = Share.all
  end

  # GET /shares/1
  # GET /shares/1.json
  def show
  end

  # GET /shares/new
  def new
    @share = Share.new
  end

  # GET /shares/1/edit
  def edit
  end

  # POST /shares
  # POST /shares.json
  def create
    @share = Share.new(share_params)

    respond_to do |format|
      if @share.save
        format.html { redirect_to @share, notice: 'Share was successfully created.' }
        format.json { render :show, status: :created, location: @share }
      else
        format.html { render :new }
        format.json { render json: @share.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /shares/1
  # PATCH/PUT /shares/1.json
  def update
    respond_to do |format|
      if @share.update(share_params)
        format.html { redirect_to @share, notice: 'Share was successfully updated.' }
        format.json { render :show, status: :ok, location: @share }
      else
        format.html { render :edit }
        format.json { render json: @share.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shares/1
  # DELETE /shares/1.json
  def destroy
    @share.destroy
    respond_to do |format|
      format.html { redirect_to shares_url, notice: 'Share was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  # GET /shares/1/notional_buy_by_investment_inline
  def notional_buy_by_investment_inline
    @_share = Share.find(params[:share][:id])
    @notional_buy = @_share.notional_buy_by_investment_of(params[:share][:notional_buy_by_investment_of])
    respond_to do |format|
      format.json
    end
  end

  # GET /shares/1/notional_buy_by_quantity_inline
  def notional_buy_by_quantity_inline
    @_share = Share.find(params[:share][:id])
    @notional_buy = @_share.notional_buy_by_quantity(params[:share][:notional_buy_by_quantity])
    respond_to do |format|
      format.json { render "notional_buy_by_investment_inline" }
    end
  end

  # GET /shares/1/notional_buy_by_price_inline
  def notional_buy_by_price_inline
    @_share = Share.find(params[:share][:id])
    if params[:notional_buy_calculation_type] == "with_investment_of"
      puts self.class.to_s + " param.price: " + self.toCalculatableNumeric(params[:share][:notional_buy_by_price])
      @notional_buy = @_share.notional_buy_by_price(self.toCalculatableNumeric(params[:share][:notional_buy_by_investment_of]), 0, self.toCalculatableNumeric(params[:share][:notional_buy_by_price]).to_f)
    else
      puts self.class.to_s + " params.price: " + self.toCalculatableNumeric(params[:share][:notional_buy_by_price])
      @notional_buy = @_share.notional_buy_by_price(0, params[:share][:notional_buy_by_quantity], self.toCalculatableNumeric(params[:share][:notional_buy_by_price]).to_f)
    end
    respond_to do |format|
      format.json { render "notional_buy_by_investment_inline" }
    end
  end

  # get /shares/1/charts_data
  def charts_data
    @daily_closing_prices = @share.daily_closing_prices.sort{ |d1, d2| d1.date_of_day <=> d2.date_of_day }
    @stock_exchange = @share.stock_exchange
    @stock_exchange_daily_closing_prices = @stock_exchange.stock_exchange_daily_closing_prices.sort{ |d1,d2| d1.date_of_day <=> d2.date_of_day }
    respond_to do |format|
      format.json
    end
  end

  # get /shares/1/charts_historical_data
  def charts_historical_data
    @portfolio_changes = @share.portfolio_changes.sort { |pc1,pc2| pc1.date_of_day <=> pc2.date_of_day }
    @historical_prices = @share.historical_prices
    #@historical_total_prices = [] << { :date_of_day => Date.parse("2008-10-01"), :total_price => 0 }

    @historical_total_prices = []
    current_share_buy_price = 0
    @historical_prices.each { |hp|
      @pc_date_of_day_hp_date_of_day = @portfolio_changes.select { |pc| hp[:date_of_day] > pc.date_of_day }.last
      if @pc_date_of_day_hp_date_of_day != nil
        current_share_buy_price = @pc_date_of_day_hp_date_of_day.share.portfolio_sums_by_date( @pc_date_of_day_hp_date_of_day.date_of_day.to_time )[:total_price]
      end
      @historical_total_prices << { :date_of_day => hp[:date_of_day], :total_price => current_share_buy_price }
    }
    respond_to do |format|
      format.json
      format.html { render :layout => false    }
    end
  end

  # get /shares/charts_datas
  def charts_datas
    @datas = Array.new
    shares = Share.sorted_by_name_isin
    shares.each do |share|
      @datas << { :share => share, :daily_closing_prices => share.daily_closing_prices.order( :date_of_day ) }
    end
    respond_to do |format|
      format.json
      #format.json { render :json => @datas }
    end
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_share
      @share = Share.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def share_params
      params.require(:share).permit(:isin, :name, :currency, :stock_exchange_id)
    end
end
