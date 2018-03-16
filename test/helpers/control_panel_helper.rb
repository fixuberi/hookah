require 'rails/test_help'
require 'capybara'
require 'capybara/dsl'
require 'capybara/webkit'

module ControlPanelHelper

  def click_plus_button
    @session.execute_script(%Q!$(".btnPlus").trigger('click')!)
  end

end