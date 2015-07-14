class StockExchangesController < ApplicationController
  before_action :set_stock_exchange, only: [:show, :edit, :update, :destroy]

  # GET /stock_exchanges
  # GET /stock_exchanges.json
  def index
    @stock_exchanges = StockExchange.all
  end

  # GET /stock_exchanges/1
  # GET /stock_exchanges/1.json
  def show
  end

  # GET /stock_exchanges/new
  def new
    @stock_exchange = StockExchange.new
  end

  # GET /stock_exchanges/1/edit
  def edit
  end

  # POST /stock_exchanges
  # POST /stock_exchanges.json
  def create
    @stock_exchange = StockExchange.new(stock_exchange_params)

    respond_to do |format|
      if @stock_exchange.save
        format.html { redirect_to @stock_exchange, notice: 'Stock exchange was successfully created.' }
        format.json { render :show, status: :created, location: @stock_exchange }
      else
        format.html { render :new }
        format.json { render json: @stock_exchange.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /stock_exchanges/1
  # PATCH/PUT /stock_exchanges/1.json
  def update
    respond_to do |format|
      if @stock_exchange.update(stock_exchange_params)
        format.html { redirect_to @stock_exchange, notice: 'Stock exchange was successfully updated.' }
        format.json { render :show, status: :ok, location: @stock_exchange }
      else
        format.html { render :edit }
        format.json { render json: @stock_exchange.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stock_exchanges/1
  # DELETE /stock_exchanges/1.json
  def destroy
    @stock_exchange.destroy
    respond_to do |format|
      format.html { redirect_to stock_exchanges_url, notice: 'Stock exchange was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_stock_exchange
      @stock_exchange = StockExchange.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def stock_exchange_params
      params.require(:stock_exchange).permit(:name, :closing_time, :timezone, :location)
    end
end
