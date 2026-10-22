Rails.application.routes.draw do
  get "/healthz", to: "health#show"

  # resources :articles
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  namespace :api do
    namespace :v1 do
      resources :articles
    end
  end
end

