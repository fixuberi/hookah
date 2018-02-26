require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'capybara'
require 'capybara/dsl'
require 'capybara/webkit'


class ActiveSupport::TestCase
  def setup_data
    @test_user = {email: 'hookahman@hookahman.ua', password: '123456'}
    @test_user1 = {email: 'vko.demo@mail.ru', password: '123456'}
    @login_page = {login_url: 'https://hookahme.nu/login',
                   login_button: '//*[@id="contentBox"]/div/section/div/div/form/div[3]/button/span'}
    @test_product = {name: 'test drink',
                     price: 50.0,
                     ingredient: {name:'Водка Nemirof', quantity_for_order: 0.1} }
    @bar_order_page = { product_list: '//*[@id="BarOrderPage"]/div[2]/div[2]/div[2]/div/div/div/div',
                        order_list: '//*[@id="barOrderBlock"]/ul',
                        new_bar_order: 'https://shf.hookahme.nu/company/bar/order?order-id=new&invoice_id=0',
                        create_order_button: '//*[@id="barOrderBlock"]/div[2]/button[2]'}
    @hookah_order_page = { url: 'https://shf.hookahme.nu/company/order/add',
                           create_order_button: 'button.js-submitBtn' }
    @test_tobacco = {name: 'Basil Blast',
                     category: 'Premium',
                     quantity_for_adding: 100,
                     quantity_for_sale: 10}
    @invoices_page = { url: 'https://shf.hookahme.nu/company/invoices'}
    @infopanel_page = { url: 'https://shf.hookahme.nu/company' }
    @id_n_param = { open: '?status=0', closed: '?status=1', deferred: '?status=2' }
  end

 def login
    @session.visit(@login_page[:login_url])
    sleep(4)
    @session.fill_in 'login',    with: @test_user[:email]
    sleep(4)
    @session.fill_in 'password', with: @test_user[:password]
    sleep(4)
    @session.find(:xpath, @login_page[:login_button]).click
    sleep(4)
    @session.visit(@infopanel_page[:url])
    sleep(1)
    assert_equal(@infopanel_page[:url], @session.current_url)
  end

  def get_product_on_orderpage(product)
    sleep(3)
    html_index = @session.find_all(:xpath, @bar_order_page[:product_list]).map(&:text)
                     .map {|s| s.include?(product)}.index(true) + 1
    @bar_order_page[:product_list] + "[#{html_index.to_s}]"
  end

  def get_status_button(product)
    html_index =@session.find_all(:xpath, '//*[@id="contentBox"]/div/div[2]/div/div[2]/table/tbody//tr')
                    .map(&:text).map {|s| s.include?(product)}.index(true)+1
    '//*[@id="contentBox"]/div/div[2]/div/div[2]/table/tbody/tr' + "[#{html_index}]" + '/td[6]'
  end

  def get_ingredient_quantity(ingredient)
    @session.visit('https://shf.hookahme.nu/company/bar/ingredient')
    sleep(3)
    html_index = @session.find_all(:xpath, '//*[@id="contentBox"]/div/div[2]/table/tbody/tr').map(&:text)
                     .map {|s| s.include?(ingredient)}.index(true) + 1
    @session.find(:xpath, '//*[@id="contentBox"]/div/div[2]/table/tbody/tr'+ "[#{html_index}]" + '/td[3]').text.to_f
  end
  def get_tobacco_quantity(tobacco)
   @session.visit('https://shf.hookahme.nu/company/inventory/get?type=tobacco')
   sleep(4)
   html_index = @session.find_all(:xpath, '//*[@id="contentBox"]/div/div[2]/table/tbody/tr').map(&:text)
                    .map {|s| s.include?(tobacco)}.index(true) + 1
   @session.find(:xpath, '//*[@id="contentBox"]/div/div[2]/table/tbody/tr[' + "#{html_index}" +']/td[7]')
                                 .text.split[0].to_i
  end

 def workshift(attr)
    if attr == 'start'
      sleep(3)
      @session.find(:xpath, '//*[@id="workShiftContainer"]/div/div[1]/div[2]/span/i').click
      sleep(3)
      assert workshift_is_open?
    end
    if attr == 'stop'
      sleep(3)
      @session.find(:xpath, '//*[@id="workShiftContainer"]/div/div[1]/div[2]/span/i').click
      sleep(3)
      @session.find('.confirmModal form button[type="submit"]').click
      sleep(5)
      assert_not workshift_is_open?
    end
 end
 def workshift_is_open?
   sleep(3)
   assert_not @session.find_all('#workShiftContainer').map(&:text).empty?
   @session.find('#workShiftContainer').text.split(' ')[-1] == "stop"
 end

 #create new invoice and bar-order with test_product. Return invoice id
 def create_bar_order(product, place_num = 66)
   @session.visit(@bar_order_page[:new_bar_order])
   assert_equal(@bar_order_page[:new_bar_order], @session.current_url)
   assert_not @session.find_all(:xpath, get_product_on_orderpage(product)).map(&:text).empty?, "товар не найден в списке доступных"
   @session.find(:xpath, get_product_on_orderpage(product)).click
   assert(@session.find_all(:xpath, @bar_order_page[:order_list]).map(&:text).map { |x| x.include?(product)}.include?(true))
   @session.fill_in 'place', with:place_num
   @session.find(:xpath, @bar_order_page[:create_order_button]).click
   sleep(4)
   assert_match '?status=0', @session.current_url, "заказ не был создан"
   @session.current_url[0, @session.current_url.size - '?status=0'.size].split('/')[-1] #invoice id
 end
  def create_hookah_order(tobacco, place_num = 66)
    @session.visit(@hookah_order_page[:url])
    sleep(4)
    @session.fill_in 'place', with: place_num
    @session.execute_script(%Q!$(".tobaccoList li:contains('#{tobacco}')").trigger('click')!)
    assert @session.find('li', text: 'Табак').[]('class').include?('selected'), "Табак не был выбран"
    @session.find(@hookah_order_page[:create_order_button]).click
    sleep(2)
    assert_match 'invoices', @session.current_url, "Кальянный заказ НЕ был создан"
  end


 def get_cashbox_summ
   @session.visit('https://shf.hookahme.nu/company/cash-box')
   { cash: @session.find('div.js-cashType p.cashSumm span:nth-child(3)').text.split(' ').join.to_f,
     ecash:@session.find('div.js-eCashType p.cashSumm span').text.split(' ').join.to_f }
 end

 def close_check(id, paymethod)
   @session.visit(@invoices_page[:url] + '/' + id + @id_n_param[:open])
   sleep(3)
   @session.execute_script("$('.js-closeInvoice').trigger('click')") #close invoiee button
   sleep(3)
   @session.find('.js-showPaymentConfirm').click #подтверждаю получение в кассу
   sleep(3)
   @session.find('.js-pay'+"#{paymethod}").click # выбрал кассу
   sleep(3)
   assert_equal(@invoices_page[:url], @session.current_url)
   @session.visit(@invoices_page[:url] + @id_n_param[:closed])
   required_attr = '.checks tbody tr[href="/company/invoices/' + id + "#{@id_n_param[:closed]}"  + '"]'
   assert @session.find_all(required_attr).map(&:text).any?, "чека нет среди закрытых"
 end
end

