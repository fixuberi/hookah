Rails.application.routes.draw do
  get 'test_result/index'

  root 'test_result#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
