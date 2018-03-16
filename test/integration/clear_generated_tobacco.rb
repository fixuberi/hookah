require 'test_helper'
require 'capybara'
require 'capybara/dsl'
require 'capybara/webkit'
require 'helpers/page_path'

class ClearTobacco < ActionDispatch::IntegrationTest
  include Capybara::DSL


  include TableHelper
  include ModalHelper
  include PagePath
  include TestEnv

  url = UrlMake.new
  INVENTORY_TOBACCO_PAGE_1 = url.make INVENTORY_TOBACCO_PATH, SUB1
  INVENTORY_TOBACCO_PAGE_2 = url.make INVENTORY_TOBACCO_PATH, SUB2

  BOTH_PAGES = [INVENTORY_TOBACCO_PAGE_1, INVENTORY_TOBACCO_PAGE_2]

  TOBACCO = 'Basil Blast'

  def setup
    @session = Capybara::Session.new(:webkit)
  end

  test "clear all tobacco except one" do
    login
    BOTH_PAGES.each do |page|
      @session.visit(page)
      sleep(3)

      while product_name_list.count > 1 do
        delete_all_position_except(TOBACCO)
      end

      assert_equal 1, product_name_list.count
    end
  end
end
