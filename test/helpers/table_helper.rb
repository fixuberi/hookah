require 'rails/test_help'
require 'capybara'
require 'capybara/dsl'
require 'capybara/webkit'
require 'test_helper'
require 'helpers/page_path'


module TableHelper
  include ModalHelper
  include PagePath
  include TestEnv

  url = UrlMake.new

  BAR_INGREDIENT_PAGE    = url.make BAR_INGREDIENT_PATH, SUB1
  COLUMN_WITH_UNIT       = %w[avg_cost breakage quantity additional_price] #есть пара нужных колонок без юнитов: расход угля на один кальян, расход наполнителя в литрах(нет пробела)

  ADD_QUANTITY_BUTTON    = 'ul.mdl-menu li:nth-child(1)'
  MOVE_POSITION_BUTTON   = 'ul > li.js-movePosition'
  DELETE_POSITION_BUTTON = 'ul > li.js-delPosition'

  def product_name_list
    full_scroll_down
    return @session.find_all('.tableBox tbody tr td.name').map(&:text)
  end

  def present_in_table_by_name?(name)
    return product_name_list.include?(name)
  end

  def get_value_from_table(incom_type, incom_value, return_type)
    row_index = find_row_index(incom_type, incom_value)
    value = @session.find('.tableBox tbody tr:nth-child(' + "#{row_index}" + ')' + ' td.' + return_type).text

      if COLUMN_WITH_UNIT.include?(return_type) && @session.current_url != BAR_INGREDIENT_PAGE
        value = value.split[0].to_f.round(1)
      elsif COLUMN_WITH_UNIT.include?(return_type) && @session.current_url == BAR_INGREDIENT_PAGE
        value = value.to_f.round(1)
      end

    return value
  end

  def has_duplicates_by_name?(product)
    full_scroll_down
    matches_count = product_name_list.map{|row| row.include?(product)}.count(true)
    if matches_count > 1
      return true
    else
      return false
    end
  end



  def delete_position_by_name(product, quantity, base_delete = false)
    full_scroll_down
    sleep(4)
    row_index = find_row_index('name', product)
    context_button(row_index).click
    @session.find(DELETE_POSITION_BUTTON).click
    sleep(4)

    assert modal_present?, "модалка удаления не появилась"

    fill_in_delete_quantity_modal(quantity, base_delete)

    submit_button_modal.click
    sleep(4)

    assert_not modal_present?, "кнопка сабмит не нажалась, модалка удаления не исчезла"
  end

  def delete_all_position_except(exception)
    list = product_name_list
    list.delete(exception)
    list.each do |product|
      delete_position_by_name(product, 9999, true)
      #list.delete(product)
    end
  end

  def add_quantity_by_name(product, quantity, price = 100)
    row_index = find_row_index('name', product)

    context_button(row_index).click
    @session.find(ADD_QUANTITY_BUTTON).click
    sleep(3)

    assert modal_present?, "модалка добавления количества не появилась"

    fill_in_add_quantity_modal(quantity, price)
    submit_button_modal.click
    sleep(5)

    assert_not modal_present?, "кнопка сабмит не нажалась, модалка не исчезла"
  end

  def move_position_by_name(product, quantity, bar, uniq_position = false)
    sleep(2)
    full_scroll_down
    row_index = find_row_index('name', product)
    sleep(3)
    context_button(row_index).click
    sleep(4)
    @session.find(MOVE_POSITION_BUTTON).click
    sleep(4)

    assert modal_present?

    selected_category = fill_in_move_position_modal(quantity, bar, uniq_position)

    return selected_category
  end




  def context_button(row_index)
    @session.find('.tableBox tbody tr:nth-child(' + "#{row_index}" + ')' + ' td.btns')
  end


  def find_row_index(incom_type, incom_value)
    return @session.find_all('.tableBox tbody tr td.' + incom_type).map(&:text).index(incom_value) + 1
  end

  def full_scroll_down
    begin
      row_count = @session.find_all('tbody tr').count
      @session.execute_script "window.scrollBy(0,10000)"
      sleep(3)
    end while row_count < @session.find_all('tbody tr').count
  end


end
