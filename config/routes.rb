Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  namespace :v1 do
    resources :users, :only => [:show, :update] do
      collection do
        get :property_owners
      end
      resources :bank_accounts
      resources :associations do
        post :create_stripe_account, on: :member
      end
      resources :walkthroughs
      resources :units, except: [:create] do
        get :unit_history, on: :member
      end
    end
    get '/download_file', to: 'downloads#download_file'
  end
end
