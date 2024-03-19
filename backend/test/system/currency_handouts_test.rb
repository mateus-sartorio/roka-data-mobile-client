require "application_system_test_case"

class CurrencyHandoutsTest < ApplicationSystemTestCase
  setup do
    @currency_handout = currency_handouts(:one)
  end

  test "visiting the index" do
    visit currency_handouts_url
    assert_selector "h1", text: "Currency handouts"
  end

  test "should create currency handout" do
    visit currency_handouts_url
    click_on "New currency handout"

    fill_in "Start date", with: @currency_handout.start_date
    fill_in "Title", with: @currency_handout.title
    fill_in "Value", with: @currency_handout.value
    click_on "Create Currency handout"

    assert_text "Currency handout was successfully created"
    click_on "Back"
  end

  test "should update Currency handout" do
    visit currency_handout_url(@currency_handout)
    click_on "Edit this currency handout", match: :first

    fill_in "Start date", with: @currency_handout.start_date
    fill_in "Title", with: @currency_handout.title
    fill_in "Value", with: @currency_handout.value
    click_on "Update Currency handout"

    assert_text "Currency handout was successfully updated"
    click_on "Back"
  end

  test "should destroy Currency handout" do
    visit currency_handout_url(@currency_handout)
    click_on "Destroy this currency handout", match: :first

    assert_text "Currency handout was successfully destroyed"
  end
end
