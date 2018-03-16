require 'rails/test_help'
require 'capybara'
require 'capybara/dsl'
require 'capybara/webkit'
require 'helpers/page_path'

module HookahOrderHelper

  include PagePath
  include TestEnv

  url = UrlMake.new

  HOOKAH_ORDER_PAGE        = url.make NEW_HOOKAH_ORDER_PATH, SUB1

  CREATE_ORDER_BUTTON_CSS  = 'button[type="submit"]'
  REQUIRED_PARTS_FOR_ORDER = %w[tobacco bowl bowlLid hookah filler coal]

  def create_hookah_order(tobacco, place_num = 66)
    @session.visit(HOOKAH_ORDER_PAGE)
    sleep(4)
    assert_equal(HOOKAH_ORDER_PAGE, @session.current_url)


    @session.fill_in 'place', with: place_num

    select_tobacco(tobacco)
    hookah_is_assembled?

    @session.save_screenshot 'scr.png'
    @session.find(CREATE_ORDER_BUTTON_CSS).click
    sleep(2)
    assert_match 'invoices', @session.current_url, "Кальянный заказ НЕ был создан"

    return invoice_id
  end



  def select_tobacco(tobacco)
    @session.execute_script(%Q!$(".tobaccoList li:contains('#{tobacco}')").trigger('click')!)
  end

  def hookah_is_assembled?
    REQUIRED_PARTS_FOR_ORDER.each do |part|
      assert @session.find('li', class: "#{part}").[]('class').include?('selected'), "#{part} не был выбран"
    end
  end

  def invoice_id
    @session.current_url.split('/')[-1]
  end



end