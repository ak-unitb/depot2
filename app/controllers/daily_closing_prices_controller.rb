class DailyClosingPricesController < ApplicationController
  before_action :set_daily_closing_price, only: [:show, :edit, :edit_inline, :update, :destroy]
  layout Proc.new { |controller| controller.request.xhr? ? 'xhr' : 'application' }

  # GET /daily_closing_prices
  # GET /daily_closing_prices.json
  def index
    @daily_closing_prices = DailyClosingPrice.all
  end

  # GET /daily_closing_prices/1
  # GET /daily_closing_prices/1.json
  def show
  end

  # GET /daily_closing_prices/new
  def new
    @daily_closing_price = DailyClosingPrice.new
  end

  # GET /daily_closing_prices/1/edit
  def edit
  end

  # GET /daily_closing_prices/1/edit_inline
  def edit_inline
  end

  # POST /daily_closing_prices
  # POST /daily_closing_prices.json
  def create
    @daily_closing_price = DailyClosingPrice.new(daily_closing_price_params)

    respond_to do |format|
      if @daily_closing_price.save
        format.html { redirect_to @daily_closing_price, notice: 'Daily closing price was successfully created.' }
        format.json { render :show, status: :created, location: @daily_closing_price }
      else
        format.html { render :new }
        format.json { render json: @daily_closing_price.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /daily_closing_prices/1
  # PATCH/PUT /daily_closing_prices/1.json
  def update
    respond_to do |format|
      if @daily_closing_price.update(daily_closing_price_params)
        format.html { redirect_to @daily_closing_price, notice: 'Daily closing price was successfully updated.' }
        format.json { render :show, status: :ok, location: @daily_closing_price }
      else
        format.html { render :edit }
        format.json { render json: @daily_closing_price.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /daily_closing_prices/1
  # PUT /daily_closing_prices/1.json
  def update_inline

    respond_to do |format|
      if @daily_closing_price.update_attributes(params[:daily_closing_price])
        @notice = 'Daily closing price was successfully updated.'
        format.html #{ render, :notice => 'Daily closing price was successfully updated.' } # redirect_to @daily_closing_price,
        format.json { head :ok }
      else
        format.html { render :action => "edit_inline" }
        format.json { render :json => @daily_closing_price.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /daily_closing_prices/1
  # DELETE /daily_closing_prices/1.json
  def destroy
    @daily_closing_price.destroy
    respond_to do |format|
      format.html { redirect_to daily_closing_prices_url, notice: 'Daily closing price was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_daily_closing_price
      @daily_closing_price = DailyClosingPrice.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def daily_closing_price_params
      params.require(:daily_closing_price).permit(:share_id, :price, :when)
    end
end
