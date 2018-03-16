require 'helpers/test_environment'

module PagePath



  BAR_INGREDIENT_PATH    = '/company/bar/ingredient'
  INVENTORY_TOBACCO_PATH = '/company/inventory/get?type=tobacco'

  NEW_BAR_ORDER_PATH     = '/company/bar/order?order-id=new&invoice_id=0'
  NEW_HOOKAH_ORDER_PATH  = '/company/order/add'

  INVOICES_PATH          = '/company/invoices/'
  CASHBOX_PATH           = '/company/cash-box'

  LOGIN_PATH             = '/login'
  INFOPANEL_PATH         = '/company'







  class UrlMake
    include TestEnv

    def make(path, sub = '')
      return PROTOCOL + sub + DOMAIN + path
    end

  end

end
