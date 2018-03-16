require 'test_helper'
require 'capybara'
require 'capybara/dsl'
require 'capybara/webkit'

class BarOrderTest < ActionDispatch::IntegrationTest
  include Capybara::DSL

  include TableHelper
  include ModalHelper
  include TestEnv
  include PagePath

  url = UrlMake.new

  INVENTORY_TOBACCO_PAGE      = url.make INVENTORY_TOBACCO_PATH, SUB1

  TOBACCO                     = 'Basil Blast'
  TOBACCO_QUANTITY_FOR_ADDING = 100


  def setup
    @session = Capybara::Session.new(:webkit)
  end

  def teardown
    workshift('stop') if workshift_is_open?
  end


  test "tabacco quantity should change after adding" do
    login
    workshift('start') unless workshift_is_open?

    @session.visit(INVENTORY_TOBACCO_PAGE)
    sleep(3)

    @tobacco_quantity = get_value_from_table('name', TOBACCO, 'quantity')

    assert_difference '@tobacco_quantity' , +TOBACCO_QUANTITY_FOR_ADDING, "количество не измннилось" do

      add_quantity_by_name(TOBACCO, TOBACCO_QUANTITY_FOR_ADDING)
      @tobacco_quantity = get_value_from_table('name', TOBACCO, 'quantity')

    end
  end
end

