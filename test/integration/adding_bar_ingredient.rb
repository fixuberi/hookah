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

  test "adding bar ingredient quantity" do
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

  #check ingredient quantitty before adding
  before_quantity = get_ingredient_quantity(@test_product[:ingredient][:name])

  #adding ingredient quantity
  html_index = @session.find_all(:xpath, '//*[@id="contentBox"]/div/div[2]/table/tbody/tr').map(&:text).map {|s| s.include?(@test_product[:ingredient][:name])}.index(true) + 1
  @session.find(:xpath, '//*[@id="contentBox"]/div/div[2]/table/tbody/tr'+ "[#{html_index}]" + '/td[6]').click
  @session.find(:xpath, '//*[@id="contentBox"]/div/div[2]/table/tbody/tr'+ "[#{html_index}]" + '/td[6]/div/ul/li[1]').click #нажал доаавить ингредиент
  @session.find(:xpath, '/html/body/div[1]/div[8]/form/div[1]/div/div[1]/div/input')
  inp_id =  @session.find('input[label="Количество"]').inspect.split('\'')[1] #достал id инпута
  @session.fill_in inp_id, with: @test_product[:ingredient][:quantity_for_adding]
  inp_id = @session.find_all('input[label]')[1].inspect.split('\'')[1]
  @session.fill_in inp_id, with: @test_product[:ingredient][:quantity_for_adding]
  @session.find('button[type="submit"]').click

  #check ingredient quantity after adding
  after_quantity = get_ingredient_quantity(@test_product[:ingredient][:name])

  expected_quantity = (before_quantity + @test_product[:ingredient][:quantity_for_adding]).round(1)
  assert_equal(expected_quantity,after_quantity)
  end
end
