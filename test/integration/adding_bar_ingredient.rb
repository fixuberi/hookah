require 'test_helper'
require 'capybara'
require 'capybara/dsl'
require 'capybara/webkit'

class AddingBarIngredient < ActionDispatch::IntegrationTest
  include Capybara::DSL


  include TableHelper
  include ModalHelper
  include PagePath
  include TestEnv

  url = UrlMake.new

  BAR_INGREDIENT_PAGE            = url.make BAR_INGREDIENT_PATH, SUB1


  INGREDIENT                     = 'Водка Nemirof'
  INGREDIENT_QUANTITY_FOR_ADDING = 1


  def setup
    @session = Capybara::Session.new(:webkit)
  end

  def teardown
    workshift('stop') if workshift_is_open?
  end

  test "bar ingredient quantity should change after adding" do
    login
    workshift('start') unless workshift_is_open?

    @session.visit(BAR_INGREDIENT_PAGE)
    sleep(3)
    @ingredient_quantity = get_value_from_table('name', INGREDIENT, 'quantity')

    assert_difference '@ingredient_quantity' , +INGREDIENT_QUANTITY_FOR_ADDING do

      add_quantity_by_name(INGREDIENT, INGREDIENT_QUANTITY_FOR_ADDING)
      @ingredient_quantity = get_value_from_table('name', INGREDIENT, 'quantity')

    end
  end
end
