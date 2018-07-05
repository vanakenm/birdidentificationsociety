Rails.application.routes.draw do
  post 'calls/voice'
  post 'calls/record'

  resources :requests
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
