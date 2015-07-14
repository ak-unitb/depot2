require 'test_helper'

class DailyClosingPricesControllerTest < ActionController::TestCase
  setup do
    @daily_closing_price = daily_closing_prices(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:daily_closing_prices)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create daily_closing_price" do
    assert_difference('DailyClosingPrice.count') do
      post :create, daily_closing_price: { price: @daily_closing_price.price, share_id: @daily_closing_price.share_id, when: @daily_closing_price.when }
    end

    assert_redirected_to daily_closing_price_path(assigns(:daily_closing_price))
  end

  test "should show daily_closing_price" do
    get :show, id: @daily_closing_price
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @daily_closing_price
    assert_response :success
  end

  test "should update daily_closing_price" do
    patch :update, id: @daily_closing_price, daily_closing_price: { price: @daily_closing_price.price, share_id: @daily_closing_price.share_id, when: @daily_closing_price.when }
    assert_redirected_to daily_closing_price_path(assigns(:daily_closing_price))
  end

  test "should destroy daily_closing_price" do
    assert_difference('DailyClosingPrice.count', -1) do
      delete :destroy, id: @daily_closing_price
    end

    assert_redirected_to daily_closing_prices_path
  end
end
