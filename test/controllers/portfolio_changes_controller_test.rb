require 'test_helper'

class PortfolioChangesControllerTest < ActionController::TestCase
  setup do
    @portfolio_change = portfolio_changes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:portfolio_changes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create portfolio_change" do
    assert_difference('PortfolioChange.count') do
      post :create, portfolio_change: { price_per_share: @portfolio_change.price_per_share, quantity: @portfolio_change.quantity, share_id: @portfolio_change.share_id, total_cost_of_order: @portfolio_change.total_cost_of_order, transaction_type: @portfolio_change.transaction_type, when: @portfolio_change.when }
    end

    assert_redirected_to portfolio_change_path(assigns(:portfolio_change))
  end

  test "should show portfolio_change" do
    get :show, id: @portfolio_change
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @portfolio_change
    assert_response :success
  end

  test "should update portfolio_change" do
    patch :update, id: @portfolio_change, portfolio_change: { price_per_share: @portfolio_change.price_per_share, quantity: @portfolio_change.quantity, share_id: @portfolio_change.share_id, total_cost_of_order: @portfolio_change.total_cost_of_order, transaction_type: @portfolio_change.transaction_type, when: @portfolio_change.when }
    assert_redirected_to portfolio_change_path(assigns(:portfolio_change))
  end

  test "should destroy portfolio_change" do
    assert_difference('PortfolioChange.count', -1) do
      delete :destroy, id: @portfolio_change
    end

    assert_redirected_to portfolio_changes_path
  end
end
