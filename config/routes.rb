Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'home#index'

  get '/weather', to: 'weather#index'
  get '/weather/data', to: 'weather#get_weather_data'
end
