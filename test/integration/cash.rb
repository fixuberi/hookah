require 'test_helper'
require 'capybara'
require 'capybara/dsl'
require 'capybara/webkit'

class BarOrderTest < ActionDispatch::IntegrationTest
  include Capybara::DSL

  def setup
    @session = Capybara::Session.new(:webkit)
    setup_data
    login
    workshift('start') unless workshift_is_open?

    @before_balance = {}
    @after_balance = {}
  end

  def teardown
    workshift('stop') if workshift_is_open?
  end

  test "cash payment" do
    #записать значения баланса наличной и безнал касс
    @before_balance = get_cashbox_summ

    #create new invoice and bar-order with test_product. Return invoice id
    @id_n_param[:id] = create_bar_order(@test_product[:name])

    #execution bar-oder
    @session.find(:xpath, get_status_button(@test_product[:name])).click
    sleep(2)
    assert_equal("ЗАВЕРШЕН", @session.find(:xpath, get_status_button(@test_product[:name])).text)

    # закыыть чек, выбрать способ оплаты - налик
    close_check(@id_n_param[:id], 'Cash')

   # посмотреть текущие значения нал и безнал кассы
     @after_balance = get_cashbox_summ

    # проверить соответствие ожиданиям про сумму в нал  и безнал кассе
    assert_equal @before_balance[:ecash], @after_balance[:ecash]
    assert_equal @before_balance[:cash]+@test_product[:price], @after_balance[:cash]
  end
end
