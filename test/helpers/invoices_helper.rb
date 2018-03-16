require 'rails/test_help'
require 'capybara'
require 'capybara/dsl'
require 'capybara/webkit'
require 'helpers/page_path'

module InvoicesHelper

  include PagePath
  include TestEnv

  url = UrlMake.new

  INVOICES_PAGE            = url.make INVOICES_PATH, SUB1

  INVOICE_LIST_CSS         =  '.checksWrapper .checks tbody tr'
  ORDER_STATUS_BUTTON_CSS  = ' td:nth-child(6)'
  CLOSE_INVOICE_BUTTON_CSS = '.js-closeInvoice'

  INVOICE_STATUS      = { OPEN: '?status=0', CLOSED: '?status=1', DEFERRED: '?status=2' }



  def close_invoice(id, paymethod)
   assert invoice_is?(:OPEN, id)

   select_invoice(:OPEN, id)
   sleep(3)

   @session.execute_script(%Q!$("#{CLOSE_INVOICE_BUTTON_CSS}").trigger('click')!)
   sleep(3)

   #confirm payment
   assert modal_present?
   confirm_payment_button_modal.click
   sleep(3)

   #choose paymethod
   assert modal_present?
   choose_paymethod_button_modal(paymethod).click
   sleep(3)

   assert invoice_is?(:CLOSED, id)
  end



  def change_order_status(type, product)
    @session.find(order_css_locator(type, product) + ORDER_STATUS_BUTTON_CSS).click
  end

  def check_order_status(type, product)
    @session.find(order_css_locator(type, product) + ORDER_STATUS_BUTTON_CSS).text
  end

  def order_css_locator(type, product)
    sleep(4)
    css_locator = 'tr.' + "#{type}" + 'Order'
    row_index = @session.find_all(css_locator).map(&:text).map {|s| s.include?(product)}.index(true)+1
    return css_locator + ':nth-child' + "(#{row_index})"
  end






  def select_invoice(status, id)
    @session.visit(INVOICES_PAGE + INVOICE_STATUS[status])
    @session.find(invoice_css_locator(status, id)).click
  end

  def invoice_is?(status, id)
    @session.visit(INVOICES_PAGE + INVOICE_STATUS[status])
    return @session.find_all(invoice_css_locator(status, id)).any?
  end

  def invoice_css_locator(status, id)
    INVOICE_LIST_CSS + "[href='/company/invoices/" + id.to_s + INVOICE_STATUS[status] + "']"
  end



end