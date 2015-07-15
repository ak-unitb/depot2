class StockExchangeDailyClosingPricesController < ApplicationController
  before_action :set_stock_exchange_daily_closing_price, only: [:show, :edit, :update, :destroy]

  # GET /stock_exchange_daily_closing_prices
  # GET /stock_exchange_daily_closing_prices.json
  def index
    @stock_exchange_daily_closing_prices = StockExchangeDailyClosingPrice.paginate( :page => params[:page], :per_page => 20 ).order( date_of_day: :desc )
  end

  # GET /stock_exchange_daily_closing_prices/1
  # GET /stock_exchange_daily_closing_prices/1.json
  def show
  end

  # GET /stock_exchange_daily_closing_prices/new
  def new
    @stock_exchange_daily_closing_price = StockExchangeDailyClosingPrice.new
  end

  # GET /stock_exchange_daily_closing_prices/1/edit
  def edit
  end

  # POST /stock_exchange_daily_closing_prices
  # POST /stock_exchange_daily_closing_prices.json
  def create
    @stock_exchange_daily_closing_price = StockExchangeDailyClosingPrice.new(stock_exchange_daily_closing_price_params)

    respond_to do |format|
      if @stock_exchange_daily_closing_price.save
        format.html { redirect_to @stock_exchange_daily_closing_price, notice: 'Stock exchange daily closing price was successfully created.' }
        format.json { render :show, status: :created, location: @stock_exchange_daily_closing_price }
      else
        format.html { render :new }
        format.json { render json: @stock_exchange_daily_closing_price.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /stock_exchange_daily_closing_prices/1
  # PATCH/PUT /stock_exchange_daily_closing_prices/1.json
  def update
    respond_to do |format|
      if @stock_exchange_daily_closing_price.update(stock_exchange_daily_closing_price_params)
        format.html { redirect_to @stock_exchange_daily_closing_price, notice: 'Stock exchange daily closing price was successfully updated.' }
        format.json { render :show, status: :ok, location: @stock_exchange_daily_closing_price }
      else
        format.html { render :edit }
        format.json { render json: @stock_exchange_daily_closing_price.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stock_exchange_daily_closing_prices/1
  # DELETE /stock_exchange_daily_closing_prices/1.json
  def destroy
    @stock_exchange_daily_closing_price.destroy
    respond_to do |format|
      format.html { redirect_to stock_exchange_daily_closing_prices_url, notice: 'Stock exchange daily closing price was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_stock_exchange_daily_closing_price
      @stock_exchange_daily_closing_price = StockExchangeDailyClosingPrice.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def stock_exchange_daily_closing_price_params
      params.require(:stock_exchange_daily_closing_price).permit(:stock_exchange_id, :price, :date_of_day)
    end
end
