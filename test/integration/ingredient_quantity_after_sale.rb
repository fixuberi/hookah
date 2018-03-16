require 'test_helper'
require 'capybara'
require 'capybara/dsl'
require 'capybara/webkit'

class BarOrderTest < ActionDispatch::IntegrationTest
  include Capybara::DSL

  include TableHelper
  include BarOrderHelper
  include InvoicesHelper

  include PagePath
  include TestEnv

  url = UrlMake.new

  BAR_INGREDIENT_PAGE = url.make BAR_INGREDIENT_PATH, SUB1


  PRODUCT                       = 'test drink'
  INGREDIENT                    = 'Водка Nemirof'
  INGREDIENT_QUANTITY_FOR_ORDER = 0.1


  def setup
    @session = Capybara::Session.new(:webkit)
  end

  def teardown
    workshift('stop') if workshift_is_open?
  end


  test "ingredient quatity should change after execution bar order - teh.karta" do
    login
    workshift('start') unless workshift_is_open?

    @session.visit(BAR_INGREDIENT_PAGE)
    sleep(4)
    @ingredient_quantity = get_value_from_table('name', INGREDIENT, 'quantity')

    assert_difference '@ingredient_quantity*10', -INGREDIENT_QUANTITY_FOR_ORDER*10 do
      @invoice_id = create_bar_order(PRODUCT)

      change_order_status('bar', PRODUCT)
      sleep(2)
      assert_equal "ЗАВЕРШЕН", check_order_status('bar', PRODUCT)

      @session.visit(BAR_INGREDIENT_PAGE)
      sleep(4)
      @ingredient_quantity = get_value_from_table('name', INGREDIENT, 'quantity')
    end

    @session.visit(INVOICES_PAGE)
    close_invoice(@invoice_id, 'Cash')
  end

end