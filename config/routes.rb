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
      resources :bank_accounts do
        post :create_bank_account, on: :collection #With plaid
        get :fetch_balance_from_plaid, on: :member
        get :fetch_all_balance_from_plaid, on: :collection
        # post :create_funding_account, on: :collection #With unityfi
        post :submit_unityfi_deposit_account, on: :collection
      end
      resources :associations do
        post :create_stripe_account, on: :member
        # post :create_association_with_plaid, on: :collection
        # put :update_association_with_plaid, on: :member
      end
      resources :walkthroughs
      resources :units, except: [:create] do
        get :unit_history, on: :member
        post :autopay_enabled, on: :member
        post :import , on: :collection
      end
      resources :expense_thresholds, :only => [:index, :show, :update, :destroy]
      resources :meeting_events, :only => [:index, :show, :create, :update, :destroy]
      resources :amenities
      resources :amenity_reservations
      resources :voting_rules
      resources :vote_managements do
        put :update_status, on: :member
      end
    end
    get '/download_file', to: 'downloads#download_file'
  end
end
