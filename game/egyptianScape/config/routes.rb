Rails.application.routes.draw do
  post '/webhooks/telegram_<place_some_big_random_token_here>' => 'webhook#callback'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
