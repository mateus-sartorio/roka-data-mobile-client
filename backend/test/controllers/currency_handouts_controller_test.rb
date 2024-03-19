require "test_helper"

class CurrencyHandoutsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @currency_handout = currency_handouts(:one)
  end

  test "should get index" do
    get currency_handouts_url
    assert_response :success
  end

  test "should get new" do
    get new_currency_handout_url
    assert_response :success
  end

  test "should create currency_handout" do
    assert_difference("CurrencyHandout.count") do
      post currency_handouts_url, params: { currency_handout: { start_date: @currency_handout.start_date, title: @currency_handout.title, value: @currency_handout.value } }
    end

    assert_redirected_to currency_handout_url(CurrencyHandout.last)
  end

  test "should show currency_handout" do
    get currency_handout_url(@currency_handout)
    assert_response :success
  end

  test "should get edit" do
    get edit_currency_handout_url(@currency_handout)
    assert_response :success
  end

  test "should update currency_handout" do
    patch currency_handout_url(@currency_handout), params: { currency_handout: { start_date: @currency_handout.start_date, title: @currency_handout.title, value: @currency_handout.value } }
    assert_redirected_to currency_handout_url(@currency_handout)
  end

  test "should destroy currency_handout" do
    assert_difference("CurrencyHandout.count", -1) do
      delete currency_handout_url(@currency_handout)
    end

    assert_redirected_to currency_handouts_url
  end
end
