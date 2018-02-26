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
                     ingredient: {name:'Водка Nemirof', quantity_for_order: 0.1} }
    @bar_order_page = { product_list: '//*[@id="BarOrderPage"]/div[2]/div[2]/div[2]/div/div/div/div',
                        order_list: '//*[@id="barOrderBlock"]/ul',
                        new_bar_order: 'https://shf.hookahme.nu/company/bar/order?order-id=new&invoice_id=0',
                        create_order_button: '//*[@id="barOrderBlock"]/div[2]/button[2]'}
    @test_tobacco = {name: 'Basil Blast',
                     category: 'Premium',
                     quantity_for_adding: 100,
                     quantity_for_sale: 10}
  end




 test "logining" do
   #login
    @session.visit(@login_page[:login_url])
    sleep(4)
    @session.fill_in 'login',    with: @test_user[:email]
    sleep(4)
    @session.fill_in 'password', with: @test_user[:password]
    sleep(4)
    @session.find(:xpath, @login_page[:login_button]).click
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
    #ending workshift
    @session.visit('https://shf.hookahme.nu/company')
    sleep(2)
    @session.find(:xpath, '//*[@id="workShiftContainer"]/div/div[1]/div[2]').click
    sleep(4)
    @session.find(:xpath, '/html/body/div[1]/div[8]/form/div/button[1]').click
    assert_equal('НАЧАТЬ', @session.find(:xpath, '//*[@id="workShiftContainer"]/div/div[1]/div[1]').text[0..5])
    #logout
    @session.find('#personal').click
    sleep(1)
    @session.find(:xpath, '/html/body/div[1]/header/div[2]/div[4]/div/ul/li[3]').click
    assert_equal('https://hookahme.nu', @session.current_url)
 end
  #test "logout" do
    #@session.visit('https://hookahme.nu/company')
    #assert_equal('https://hookahme.nu/company', @session.current_url)
   # sleep(4)
    #@session.find('#personal').click
    #sleep(1)
    #@session.find(:xpath, '/html/body/div[1]/header/div[2]/div[4]/div/ul/li[3]').click
    #assert_equal('https://hookahme.nu', @session.current_url)
  #end

  test "hookah order tobacco quantity" do
    #login
    @session.visit(@login_page[:login_url])
    sleep(4)
    @session.fill_in 'login',    with: @test_user[:email]
    sleep(4)
    @session.fill_in 'password', with: @test_user[:password]
    sleep(4)
    @session.find(:xpath, @login_page[:login_button]).click
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
    #before-check tobacco qantity
    before_quantity = get_tobacco_quantity(@test_tobacco[:name])
    #create hookah order
    @session.visit( 'https://shf.hookahme.nu/company/order/add')
    @session.fill_in 'place', with:1
    @session.execute_script(%Q!$(".tobaccoList li:contains('#{@test_tobacco[:name]}')").trigger('click')!)
    assert @session.find('li', text: 'Табак').[]('class').include?('selected'), "Табак не был выбран"
    @session.find('button.js-submitBtn').click
    assert_match 'invoices', @session.current_url, "Заказ не был создан"
    @session.find(:xpath, get_status_button(@test_tobacco[:category])).click
    assert_equal 'ЗАВЕРШИТЬ', @session.find(:xpath, get_status_button(@test_tobacco[:category])).text
    @session.find(:xpath, get_status_button(@test_tobacco[:category])).click
    assert_equal 'ЗАВЕРШЕН', @session.find(:xpath, get_status_button(@test_tobacco[:category])).text

    #check ingredient quantity after sale
    after_quantity = get_tobacco_quantity(@test_tobacco[:name])
    expected_quantity = before_quantity - @test_tobacco[:quantity_for_sale]
    assert_equal(expected_quantity,after_quantity)
  end
end


