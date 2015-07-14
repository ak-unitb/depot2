class PortfolioChangesController < ApplicationController
  before_action :set_portfolio_change, only: [:show, :edit, :update, :destroy]

  # GET /portfolio_changes
  # GET /portfolio_changes.json
  def index
    @portfolio_changes = PortfolioChange.all
  end

  # GET /portfolio_changes/1
  # GET /portfolio_changes/1.json
  def show
  end

  # GET /portfolio_changes/new
  def new
    @portfolio_change = PortfolioChange.new
  end

  # GET /portfolio_changes/1/edit
  def edit
  end

  # POST /portfolio_changes
  # POST /portfolio_changes.json
  def create
    @portfolio_change = PortfolioChange.new(portfolio_change_params)

    respond_to do |format|
      if @portfolio_change.save
        format.html { redirect_to @portfolio_change, notice: 'Portfolio change was successfully created.' }
        format.json { render :show, status: :created, location: @portfolio_change }
      else
        format.html { render :new }
        format.json { render json: @portfolio_change.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /portfolio_changes/1
  # PATCH/PUT /portfolio_changes/1.json
  def update
    respond_to do |format|
      if @portfolio_change.update(portfolio_change_params)
        format.html { redirect_to @portfolio_change, notice: 'Portfolio change was successfully updated.' }
        format.json { render :show, status: :ok, location: @portfolio_change }
      else
        format.html { render :edit }
        format.json { render json: @portfolio_change.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /portfolio_changes/1
  # DELETE /portfolio_changes/1.json
  def destroy
    @portfolio_change.destroy
    respond_to do |format|
      format.html { redirect_to portfolio_changes_url, notice: 'Portfolio change was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_portfolio_change
      @portfolio_change = PortfolioChange.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def portfolio_change_params
      params.require(:portfolio_change).permit(:share_id, :transaction_type, :quantity, :price_per_share, :total_cost_of_order, :when)
    end
end
