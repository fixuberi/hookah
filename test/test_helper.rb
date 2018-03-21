require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'capybara'
require 'capybara/dsl'
require 'capybara/webkit'
require 'helpers/helpers_list'
require 'helpers/page_path'
require "minitest/autorun"
require "minitest/reporters"

Minitest::Reporters.use! Minitest::Reporters::HtmlReporter.new(reports_dir: 'app/views/test_result')
ActionDispatch::IntegrationTest.extend Minitest::Spec::DSL


class ActiveSupport::TestCase
  include ModalHelper

  include PagePath
  include TestEnv



  url  = UrlMake.new

  LOGIN_PAGE          = url.make LOGIN_PATH
  INFOPANEL_PAGE       = url.make INFOPANEL_PATH, SUB1
  LOGIN_BUTTON        = '//*[@id="contentBox"]/div/section/div/div/form/div[3]/button/span'
  WORKSHIFT_BUTTON_CSS   = 'div.timeBlockControl'
  WORKSHIFT_BLOCK_CSS = '#workShiftContainer'

  USER_EMAIL          = 'hookahman@hookahman.ua'
  USER_PASS           = '123456'


 def login
    @session.visit(LOGIN_PAGE)
    sleep(4)
    @session.fill_in 'login',    with: USER_EMAIL
    sleep(4)
    @session.fill_in 'password', with: USER_PASS
    sleep(4)
    @session.find(:xpath, LOGIN_BUTTON).click
    sleep(4)
    @session.visit(INFOPANEL_PAGE)
    sleep(1)
    assert_equal(INFOPANEL_PAGE, @session.current_url)
 end





 def workshift(attr)
    if attr == 'start'
      sleep(3)
      @session.find(WORKSHIFT_BUTTON_CSS).click
      sleep(3)

      assert workshift_is_open?
    end
    if attr == 'stop'
      sleep(3)
      @session.find(WORKSHIFT_BUTTON_CSS).click
      sleep(3)

      assert modal_present?
      submit_button_modal.click
      sleep(5)
      assert_not modal_present?

      assert_not workshift_is_open?
    end
 end

 def workshift_is_open?
   sleep(3)
   assert_not @session.find_all(WORKSHIFT_BLOCK_CSS).map(&:text).empty?
   @session.find(WORKSHIFT_BLOCK_CSS).text.split(' ')[-1] == "stop"
 end




end

