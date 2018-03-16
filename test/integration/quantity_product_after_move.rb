require 'test_helper'
require 'capybara'
require 'capybara/dsl'
require 'capybara/webkit'

class BarOrderTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  
  include TableHelper
  include ModalHelper
  include ControlPanelHelper

  include PagePath
  include TestEnv

  url = UrlMake.new

  INVENTORY_TOBACCO_PAGE_1 = url.make INVENTORY_TOBACCO_PATH, SUB1
  INVENTORY_TOBACCO_PAGE_2 = url.make INVENTORY_TOBACCO_PATH, SUB2



  TOBACCO = 'Basil Blast'
  TOBACCO_QUANTITY_FOR_MOVING = 50



  def setup
    @session = Capybara::Session.new(:webkit)
  end





  test "displaced uniq tobacco should have price category" do
    login
    workshift('stop') if workshift_is_open?

    @session.visit(INVENTORY_TOBACCO_PAGE_2)

    click_plus_button
    sleep(3)

    assert modal_present?

    tobacco_name = fill_in_add_new_tobacco_modal
    next_button_modal.click
    submit_button_modal.click

    selected_category = move_position_by_name(tobacco_name, TOBACCO_QUANTITY_FOR_MOVING, SUB1_NAME, true)
    next_button_modal.click
    sleep(3)
    submit_button_modal.click
    sleep(4)
    assert_not modal_present?

    @session.visit(INVENTORY_TOBACCO_PAGE_1)
    full_scroll_down
    assert present_in_table_by_name?(tobacco_name), "перемещенного табака нет в инвентаре"

    assert_equal  selected_category, get_value_from_table('name', tobacco_name, 'priceCategory')

  end

  test "movement uniq tobacco doesn't work if price category not defined" do
    login
    workshift('stop') if workshift_is_open?

    @session.visit(INVENTORY_TOBACCO_PAGE_1)

    click_plus_button
    sleep(3)

    assert modal_present?

    tobacco_name = fill_in_add_new_tobacco_modal
    next_button_modal.click
    submit_button_modal.click

    move_position_by_name(tobacco_name, TOBACCO_QUANTITY_FOR_MOVING, SUB2_NAME)
    next_button_modal.click
    sleep(3)

    assert @session.find_all('div.input-field span').map(&:text).include?('Поле не может быть пустым')
  end

  test "move product shouldn't create dublicates" do
    login
    workshift('stop') if workshift_is_open?

    @session.visit(INVENTORY_TOBACCO_PAGE_1)
    move_position_by_name(TOBACCO, TOBACCO_QUANTITY_FOR_MOVING, SUB2_NAME)
    submit_button_modal.click
    sleep(4)
    assert_not modal_present?


    @session.visit(INVENTORY_TOBACCO_PAGE_2)
    sleep(3)
    assert_not has_duplicates_by_name?(TOBACCO)

    #move back
    move_position_by_name(TOBACCO, TOBACCO_QUANTITY_FOR_MOVING, SUB1_NAME)
    submit_button_modal.click
    sleep(4)
    assert_not modal_present?
  end

  test "product quantity should change after move" do
    login
    workshift('stop') if workshift_is_open?

    @session.visit(INVENTORY_TOBACCO_PAGE_2)
    sleep(3)
    quantity_in_2_bar = get_value_from_table('name', TOBACCO, 'quantity')
    @session.visit(INVENTORY_TOBACCO_PAGE_1)
    sleep(3)
    quantity_in_1_bar = get_value_from_table('name', TOBACCO, 'quantity')

    move_position_by_name(TOBACCO, TOBACCO_QUANTITY_FOR_MOVING, SUB2_NAME)
    submit_button_modal.click
    sleep(4)
    assert_not modal_present?

    assert_equal quantity_in_1_bar - TOBACCO_QUANTITY_FOR_MOVING , get_value_from_table('name', TOBACCO, 'quantity')

    @session.visit(INVENTORY_TOBACCO_PAGE_2)
    assert_equal quantity_in_2_bar + TOBACCO_QUANTITY_FOR_MOVING , get_value_from_table('name', TOBACCO, 'quantity')


    #move back
    move_position_by_name(TOBACCO, TOBACCO_QUANTITY_FOR_MOVING, SUB1_NAME)
    submit_button_modal.click
    sleep(4)
    assert_not modal_present?
  end
end