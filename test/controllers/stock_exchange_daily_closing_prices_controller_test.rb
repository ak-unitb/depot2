require 'test_helper'

class StockExchangeDailyClosingPricesControllerTest < ActionController::TestCase
  setup do
    @stock_exchange_daily_closing_price = stock_exchange_daily_closing_prices(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:stock_exchange_daily_closing_prices)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create stock_exchange_daily_closing_price" do
    assert_difference('StockExchangeDailyClosingPrice.count') do
      post :create, stock_exchange_daily_closing_price: { price: @stock_exchange_daily_closing_price.price, stockExchange_id: @stock_exchange_daily_closing_price.stockExchange_id, date_of_day: @stock_exchange_daily_closing_price.date_of_day }
    end

    assert_redirected_to stock_exchange_daily_closing_price_path(assigns(:stock_exchange_daily_closing_price))
  end

  test "should show stock_exchange_daily_closing_price" do
    get :show, id: @stock_exchange_daily_closing_price
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @stock_exchange_daily_closing_price
    assert_response :success
  end

  test "should update stock_exchange_daily_closing_price" do
    patch :update, id: @stock_exchange_daily_closing_price, stock_exchange_daily_closing_price: { price: @stock_exchange_daily_closing_price.price, stockExchange_id: @stock_exchange_daily_closing_price.stockExchange_id, date_of_day: @stock_exchange_daily_closing_price.date_of_day }
    assert_redirected_to stock_exchange_daily_closing_price_path(assigns(:stock_exchange_daily_closing_price))
  end

  test "should destroy stock_exchange_daily_closing_price" do
    assert_difference('StockExchangeDailyClosingPrice.count', -1) do
      delete :destroy, id: @stock_exchange_daily_closing_price
    end

    assert_redirected_to stock_exchange_daily_closing_prices_path
  end
end
