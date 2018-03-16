require 'rails/test_help'
require 'capybara'
require 'capybara/dsl'
require 'capybara/webkit'
require 'helpers/page_path'

module BarOrderHelper

  include PagePath
  include TestEnv

  url = UrlMake.new

  BAR_ORDER_PAGE            = url.make NEW_BAR_ORDER_PATH, SUB1
  INVOICE_STATUS            = { OPEN: '?status=0', CLOSED: '?status=1', DEFERRED: '?status=2' }

  PRODUCT_LIST_XPATH        = '//*[@id="BarOrderPage"]/div[2]/div[2]/div[2]/div/div/div/div'
  ORDER_LIST_XPATH          = '//*[@id="barOrderBlock"]/ul'
  CREATE_ORDER_BUTTON_XPATH = '//*[@id="barOrderBlock"]/div[2]/button[2]'

  TEST_PRODUCT              = 'test drink'



  def create_bar_order(product, place_num = 66)

   @session.visit(BAR_ORDER_PAGE)
   sleep(4)
   assert_equal(BAR_ORDER_PAGE, @session.current_url)

   @session.fill_in 'place', with:place_num

   assert in_product_list?(product)
   @session.find(:xpath, in_product_list_xpath(product)).click
   assert in_order_list?(product)

   @session.find(:xpath, CREATE_ORDER_BUTTON_XPATH).click
   sleep(4)
   assert_match INVOICE_STATUS[:OPEN], @session.current_url, "заказ не был создан"

   return invoice_id
  end


  def in_product_list_xpath(product)
    sleep(3)
    row_index = @session.find_all(:xpath, PRODUCT_LIST_XPATH).map(&:text)
                    .map {|row| row.include?(product)}.index(true) + 1
    return PRODUCT_LIST_XPATH + "[#{row_index.to_s}]"
  end

  def in_product_list?(product)
    @session.find_all(:xpath, PRODUCT_LIST_XPATH).map(&:text).join.include?(product)
  end

  def in_order_list?(product)
    @session.find_all(:xpath, ORDER_LIST_XPATH).map(&:text).join.include?(product)
  end

  def invoice_id
    @session.current_url.split('/')[-1].split('?')[0]
  end


end