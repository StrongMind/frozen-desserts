Rails.application.routes.draw do
  resources :toppings
  resources :desserts
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "desserts#index"

  get "/up", to: proc { [200, {}, ["ok"]] },
      as: :rails_health_check

end
