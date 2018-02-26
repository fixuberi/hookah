require 'test_helper'
require 'capybara'
require 'capybara/dsl'
require 'capybara/webkit'

class BarOrderTest < ActionDispatch::IntegrationTest
  include Capybara::DSL

  def setup
    @session = Capybara::Session.new(:webkit)
    @test_user = {email: 'hookahman@hookahman.ua',
                  password: '123456'}
    @test_user1 = {email: 'vko.demo@mail.ru',
                   password: '123456'}
    @login_page = {login_url: 'https://hookahme.nu/login',
                   login_button: '//*[@id="contentBox"]/div/section/div/div/form/div[3]/button/span'}
    @test_product = {name: 'test drink',
                     ingredient: {name:'Водка Nemirof', quantity_for_order: 0.1, quantity_for_adding: 10.0} }
    @bar_order_page = { product_list: '//*[@id="BarOrderPage"]/div[2]/div[2]/div[2]/div/div/div/div',
                        order_list: '//*[@id="barOrderBlock"]/ul',
                        new_bar_order: 'https://shf.hookahme.nu/company/bar/order?order-id=new&invoice_id=0',
                        create_order_button: '//*[@id="barOrderBlock"]/div[2]/button[2]'}

  end

  test "writing_of_ingredient_quatity_after_sale" do
    #login
    login
    sleep(5)
    assert_equal('https://hookahme.nu/company', @session.current_url)
    @session.visit(@login_page[:login_url])
    assert_not_equal(@login_page[:login_url], @session.current_url)

    #starting workshift
    @session.visit('https://shf.hookahme.nu/company')
    sleep(1)
    assert_equal('https://shf.hookahme.nu/company', @session.current_url)
    @session.find(:xpath, '//*[@id="workShiftContainer"]/div/div[1]/div[2]/span/i').click
    assert_equal('00:00', @session.find(:xpath, '//*[@id="timer"]').text[0..4])

    #check ingredient quantitty before sale
    before_quantity = get_ingredient_quantity(@test_product[:ingredient][:name])

    #create new invoice and bar-order with test_product
    @session.visit(@bar_order_page[:new_bar_order])
    assert_equal(@bar_order_page[:new_bar_order], @session.current_url)
    @session.find(:xpath, get_product_on_orderpage(@test_product[:name])).click
    assert(@session.find_all(:xpath, @bar_order_page[:order_list]).map(&:text).map { |x| x.include?(@test_product[:name])}.include?(true))
    @session.fill_in 'place', with:1
    @session.find(:xpath, @bar_order_page[:create_order_button]).click
    sleep(4)
    assert_match 'company/invoices', @session.current_url
    #execution bar-oder
    @session.find(:xpath, get_status_button(@test_product[:name])).click
    sleep(2)
    assert_equal("ЗАВЕРШЕН", @session.find(:xpath, get_status_button(@test_product[:name])).text)

    #check ingredient quantity after sale
    expected_quantity = (before_quantity - @test_product[:ingredient][:quantity_for_order]).round(1)
    assert_equal( expected_quantity, get_ingredient_quantity(@test_product[:ingredient][:name]) )
  end

  #еще тут не помешает заоончить смену и разлогиниться
end