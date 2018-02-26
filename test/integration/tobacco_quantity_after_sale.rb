require 'test_helper'
require 'capybara'
require 'capybara/dsl'
require 'capybara/webkit'

class BarOrderTest < ActionDispatch::IntegrationTest
  include Capybara::DSL

  def setup
    @session = Capybara::Session.new(:webkit)
    setup_data
    login
    workshift('start') unless workshift_is_open?
  end

  def teardown
    workshift('stop') if workshift_is_open?
  end

  test "hookah order tobacco quantity" do
    #before-check tobacco qantity
    before_quantity = get_tobacco_quantity(@test_tobacco[:name])
    #create hookah order
    create_hookah_order(@test_tobacco[:name])

    @session.find(:xpath, get_status_button(@test_tobacco[:category])).click
    sleep(1)
    assert_equal 'ЗАВЕРШИТЬ', @session.find(:xpath, get_status_button(@test_tobacco[:category])).text
    @session.find(:xpath, get_status_button(@test_tobacco[:category])).click
    sleep(1)
    assert_equal 'ЗАВЕРШЕН', @session.find(:xpath, get_status_button(@test_tobacco[:category])).text

    #check ingredient quantity after sale
    after_quantity = get_tobacco_quantity(@test_tobacco[:name])
    expected_quantity = before_quantity - @test_tobacco[:quantity_for_sale]
    assert_equal(expected_quantity,after_quantity)
  end
end