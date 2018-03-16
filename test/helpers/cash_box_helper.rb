require 'rails/test_help'
require 'capybara'
require 'capybara/dsl'
require 'capybara/webkit'
require 'helpers/page_path'

module CashBoxHelper
  include PagePath
  include TestEnv

  url = UrlMake.new

  CASHBOX_PAGE        = url.make CASHBOX_PATH, SUB1

  CASH_SUMM_CSS       = 'div.js-cashType p.cashSumm span:nth-child(3)'
  ECASH_SUMM_CSS      = 'div.js-eCashType p.cashSumm span'

  def get_cashbox_summ
    @session.visit(CASHBOX_PAGE)

   return {
       cash: @session.find(CASH_SUMM_CSS).text.split(' ').join.to_f,
       ecash:@session.find(ECASH_SUMM_CSS).text.split(' ').join.to_f
   }
 end

end