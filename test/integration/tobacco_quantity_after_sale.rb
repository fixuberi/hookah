require 'test_helper'
require 'capybara'
require 'capybara/dsl'
require 'capybara/webkit'

class TobaccoQuantity < ActionDispatch::IntegrationTest
  include Capybara::DSL

  include TableHelper
  include HookahOrderHelper
  include InvoicesHelper
  include ModalHelper

  include PagePath
  include TestEnv

  url = UrlMake.new

  TOBACCO_PAGE               = url.make INVENTORY_TOBACCO_PATH, SUB1
  INVOICES_PAGE              = url.make INVOICES_PATH, SUB1

  TOBACCO                    = 'Basil Blast'
  TOBACCO_QUANTITY_FOR_ORDER = 10.0
  TOBACCO_PRICE_CATEGORY     = 'Medium'


  def setup
    @session = Capybara::Session.new(:webkit)
  end

  def teardown
    workshift('stop') if workshift_is_open?
  end


  test "tobacco quantity should change after execution hookah order" do
    login
    workshift('start') unless workshift_is_open?

    @session.visit(TOBACCO_PAGE)
    sleep(4)
    @tobacco_quantity = get_value_from_table('name', TOBACCO, 'quantity')


    assert_difference  '@tobacco_quantity', -TOBACCO_QUANTITY_FOR_ORDER do
      @invoice_id = create_hookah_order(TOBACCO)

      change_order_status('hookah', TOBACCO_PRICE_CATEGORY)
      sleep(1)
      assert_equal "ЗАВЕРШИТЬ", check_order_status('hookah', TOBACCO_PRICE_CATEGORY)

      change_order_status('hookah', TOBACCO_PRICE_CATEGORY)
      sleep(1)
      assert_equal "ЗАВЕРШЕН", check_order_status('hookah', TOBACCO_PRICE_CATEGORY)

      @session.visit(TOBACCO_PAGE)
      sleep(4)
      @tobacco_quantity = get_value_from_table('name', TOBACCO, 'quantity')
    end

    @session.visit(INVOICES_PAGE)
    close_invoice(@invoice_id, 'Cash')
  end
end