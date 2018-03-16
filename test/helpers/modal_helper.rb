require 'rails/test_help'
require 'capybara'
require 'capybara/dsl'
require 'capybara/webkit'

module ModalHelper

  MODAL_BLOCK_CSS            = 'div.mdl-dialog'
  CONFIRM_PAYMENT_BUTTON_CSS = '.js-showPaymentConfirm'

  def modal_present?
    @session.find_all(MODAL_BLOCK_CSS).any?
  end


  #FILLERS
  def  fill_in_delete_quantity_modal(quantity, base_delete)
    sleep(4)
     @session.find_all('div.input-field')[0].fill_in with: quantity
     @session.find_all('div.input-field')[-1].fill_in with: "test delete product, delete from base - #{base_delete}"

     if base_delete
       @session.execute_script(%Q!$("input#remainInDb").trigger('click')!)
     end

  end

  def fill_in_add_quantity_modal(quantity, price)
    @session.find_all('div.input-field')[0].fill_in with: quantity
    @session.find_all('div.input-field')[1].fill_in with: price
  end


  def fill_in_move_position_modal(quantity, bar, uniq_position = false)
    @session.find_all('div.input-field')[0].click # первы инпут в модалке он же селект заведения
    variant_index = @session.find_all("ul.dropdown-content li").map(&:text).index("#{bar}")+2

    @session.find('ul.dropdown-content li:nth-child' + "(#{variant_index})").click
    sleep(3)
    @session.find_all('div.input-field')[-1].fill_in with: quantity

    if uniq_position
      @session.find_all('div.input-field')[1].click #select of price category
      sleep(4)
      selected_category = @session.find('ul.dropdown-content li:nth-child' + "(2)").text
      @session.find('ul.dropdown-content li:nth-child' + "(2)").click
      return selected_category
    end
  end




  #BUTTONS
  def next_button_modal
    @session.find('.js-nextStep')
  end

  def submit_button_modal
    @session.find('button[type="submit"]')
  end

  def confirm_payment_button_modal
    @session.find(CONFIRM_PAYMENT_BUTTON_CSS)
  end

  def choose_paymethod_button_modal(paymethod)
    @session.find('.js-pay'+"#{paymethod}")
  end

  #complex fill
  def fill_in_add_new_tobacco_modal(brand = rand_str, name = rand_str, quantity = 100, price = 100)
    sleep(5)
    @session.find_all('div.input-field')[0].click
    @session.find_all('div.input-field')[0].find('ul li:last-child').click #выбаал пункт добавить свой бренд
    @session.execute_script(%Q!$(".step-tobacco-1 .row:nth-child(1) .col:nth-child(1) .select-dropdown").val("#{brand}")!)
    @session.execute_script(%Q!$(".step-tobacco-1 .row:nth-child(1) .col:nth-child(2) #modelInput").val("#{name}")!)

    @session.find_all('.input-field')[2].fill_in with:'description'


    @session.find_all('div.input-field')[3].click
    @session.find_all('div.input-field')[3].find('ul li:nth-child(2)').click #первый попавшийся вкус табака выбрал

    @session.find_all('div.input-field')[4].fill_in with: quantity
    @session.find_all('div.input-field')[5].fill_in with: price

    @session.find_all('div.input-field')[6].click
    @session.find_all('div.input-field')[6].find('ul li:nth-child(2)').text
    @session.find_all('div.input-field')[6].find('ul li:nth-child(2)').click #выбрал первую попавшуюся ценовую категорию

    return name
  end

  def rand_str
    (0...15).map { (65 + rand(26)).chr }.join
  end
end