require 'test_helper'
require 'capybara'
require 'capybara/dsl'
require 'capybara/webkit'

class CashBox < ActionDispatch::IntegrationTest
  include Capybara::DSL

  include BarOrderHelper
  include CashBoxHelper
  include InvoicesHelper
  include ModalHelper


  PRODUCT       = 'test drink'
  PRODUCT_PRICE = 50.0

  def setup
    @session = Capybara::Session.new(:webkit)
    @before_balance = {}
    @after_balance = {}
  end


  def teardown
    workshift('stop') if workshift_is_open?
  end

  test "cashbox summ should change after sale in both paymethods" do
    login
    workshift('start') unless workshift_is_open?

    ['Cash','ECash'].each_with_index do |paymethod, index|

      @before_balance = get_cashbox_summ

      @invoice_id = create_bar_order(PRODUCT)
      sleep(3)

      #после создания заказа попадаем на страницу продаж
      select_invoice(:OPEN, @invoice_id)
      assert_equal("ВЫПОЛНИТЬ", check_order_status('bar', PRODUCT))

      change_order_status('bar', PRODUCT)
      assert_equal("ЗАВЕРШЕН", check_order_status('bar', PRODUCT))

      close_invoice(@invoice_id, paymethod)

      @after_balance = get_cashbox_summ

      if index == 0
        assert_equal @before_balance[:ecash] , @after_balance[:ecash]
        assert_equal @before_balance[:cash] + PRODUCT_PRICE , @after_balance[:cash]
      else
        assert_equal @before_balance[:cash] , @after_balance[:cash]
        assert_equal @before_balance[:ecash] + PRODUCT_PRICE , @after_balance[:ecash]
      end
    end
  end

end



