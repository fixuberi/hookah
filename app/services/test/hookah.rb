require 'capybara'
require 'capybara/dsl'
require 'capybara/webkit'

class Test::Hookah < BaseService
  include Capybara::DSL

  def initialize
    @session = Capybara::Session.new(:webkit)
    @test_user = {email: 'hookahman@hookahman.ua',
                  password: '123456'}
    @login_page = {login_url: 'https://hookahme.nu/login',
                   login_button: '//*[@id="contentBox"]/div/section/div/div/form/div[3]/button/span'}
    @test_product = {name: 'test drink',
                     ingredient: {name:'Водка Nemirof', quantity_for_order: 0.1} }
    @bar_order_page = { product_list: '//*[@id="BarOrderPage"]/div[2]/div[2]/div[2]/div/div/div/div',
                        order_list: '//*[@id="barOrderBlock"]/ul',
                        new_bar_order: 'https://shf.hookahme.nu/company/bar/order?order-id=new&invoice_id=0',
                        create_order_button: '//*[@id="barOrderBlock"]/div[2]/button[2]'}
  end

  def call
    login
    start_workshift
    test_drink
  end

  def login
    @session.visit(@login_page[:login_url])
    sleep(2)
    @session.fill_in 'login',    with: @test_user[:email]
    sleep(2)
    @session.fill_in 'password', with: @test_user[:password]
    sleep(2)
    @session.find(:xpath, @login_page[:login_button]).click
    sleep(2)
    @session.visit('https://shf.hookahme.nu/company')
    puts @session.current_url
  end
  def logout
    @session.visit('https://hookahme.nu/company')
    @session.find('#personal').click
    @session.find(:xpath, '/html/body/div[1]/header/div[2]/div[4]/div/ul/li[3]').click
  end


  def start_workshift
    @session.visit('https://shf.hookahme.nu/company')
    puts @session.current_url
    @session.find(:xpath, '//*[@id="workShiftContainer"]/div/div[1]/div[2]/span/i').click
    sleep(10)
    puts @session.find(:xpath, '//*[@id="timer"]').text[0..4] == '00:00' ? "WorkShift was started" : 'WorkShift was not start'
  end


  def test_drink
    ingredient_quantity = get_ingredient_quantity(@test_product[:ingredient][:name])
    puts "#{@test_product[:ingredient][:name]} - #{ingredient_quantity}"
    #НАЧАЛО СОЗДАНИЕ И ВЫПОЛНЕНИЕ БАРНОГО ЗАКАЗА
    @session.visit(@bar_order_page[:new_bar_order])
    puts @session.find(:xpath, '//*[@id="BarOrderPage"]/div[1]/span') ? "GO TO new bar order" : "error new order bar"
    @session.find(:xpath, get_product_on_orderpage(@test_product[:name])).click
    if  @session.find_all(:xpath, @bar_order_page[:order_list]).map(&:text).map { |x| x.include?(@test_product[:name])}.include?(true)
      puts "product added to order list"
    end
    @session.fill_in 'place', with:1
    @session.find(:xpath, @bar_order_page[:create_order_button]).click
    # /https:\/\/shf.hookahme.nu\/company\/invoices\/[:digit]\?status=0/.match @session.current_url  тут я пытаюсь проверить был ли переход на страницу только что открытого чека
    @session.find(:xpath, get_status_button(@test_product[:name])).click
    if @session.find(:xpath, get_status_button(@test_product[:name])).text == "ЗАВЕРШЕН"
      puts "#{@test_product[:name]} order completed"
    end
    #КОНЕЦ СОЗДАНИЕ И ВЫПОЛНЕНИЕ БАРНОГО ЗАКАЗА
    if get_ingredient_quantity(@test_product[:ingredient][:name]) == (ingredient_quantity - @test_product[:ingredient][:quantity_for_order]).round(1)
      puts "test passed"
    end
  end



  def get_product_on_orderpage(product)
    html_index = @session.find_all(:xpath, @bar_order_page[:product_list]).map(&:text).map {|s| s.include?(product)}.index(true) + 1
    @bar_order_page[:product_list] + "[#{html_index.to_s}]"
  end
  def get_status_button(product)
    html_index =@session.find_all(:xpath, '//*[@id="contentBox"]/div/div[2]/div/div[2]/table/tbody').map(&:text).map {|s| s.include?(product)}.index(true)+1
    '//*[@id="contentBox"]/div/div[2]/div/div[2]/table/tbody' + "[#{html_index}]" + '/tr/td[6]'
  end
  def get_ingredient_quantity(ingredient)
    @session.visit('https://shf.hookahme.nu/company/bar/ingredient')
    html_index = @session.find_all(:xpath, '//*[@id="contentBox"]/div/div[2]/table/tbody/tr').map(&:text).map {|s| s.include?(ingredient)}.index(true) + 1
    @session.find(:xpath, '//*[@id="contentBox"]/div/div[2]/table/tbody/tr'+ "[#{html_index}]" + '/td[3]').text.to_f
  end
  def test_hookah
    #
    @session.visit('https://shf.hookahme.nu/company/inventory/get?type=tobacco')
    html_index = @session.find_all(:xpath, '//*[@id="contentBox"]/div/div[2]/table/tbody/tr').map(&:text).map {|s| s.include?('Basil Blast')}.index(true) + 1
    tobacco_quantity = @session.find(:xpath, '//*[@id="contentBox"]/div/div[2]/table/tbody/tr[' + "#{html_index}" + ']/td[7]').text.split[0].to_f
    # записал количество до закзза
    @session.visit('https://shf.hookahme.nu/company/order/add')

  end

end