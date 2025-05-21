require "sidekiq/web" # require the web UI

Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  mount Sidekiq::Web => "/sidekiq" # access it at http://localhost:3000/sidekiq

  namespace :api do
    # Client authentication
    post "/client/login", to: "client_sessions#create"
    delete "/client/logout", to: "client_sessions#destroy"

    # Job seeker authentication
    post "/job-seeker/login", to: "job_seeker_sessions#create"
    delete "/job-seeker/logout", to: "job_seeker_sessions#destroy"

    # Opportunities routes
    resources :opportunities, only: [ :index, :create ] do
      member do
        post :apply
      end
    end
  end
end
