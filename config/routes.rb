Rails.application.routes.draw do
  # Root route
  root "dashboard#index"

  # Authentication routes
  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"

  # User registration
  get "/signup", to: "users#new"
  post "/signup", to: "users#create"

  # Main app routes
  get "/dashboard", to: "dashboard#index"

  # Game routes (to be added later)
  resources :lessons, only: [:index, :show] do
    member do
      post :complete
    end
  end

  resources :trades do
    member do
      patch :close
    end
  end

  resources :badges, only: [:index]
  resources :portfolios, only: [:index, :show]

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
