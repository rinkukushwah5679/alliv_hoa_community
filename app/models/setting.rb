# RailsSettings Model
class Setting < RailsSettings::Base
  cache_prefix { "v1" }

  after_commit :clear_cache

  # Define your fields
  # field :host, type: :string, default: "http://localhost:3000"
  # field :default_locale, default: "en", type: :string
  # field :confirmable_enable, default: "0", type: :boolean
  # field :admin_emails, default: "admin@rubyonrails.org", type: :array
  # field :omniauth_google_client_id, default: (ENV["OMNIAUTH_GOOGLE_CLIENT_ID"] || ""), type: :string, readonly: true
  # field :omniauth_google_client_secret, default: (ENV["OMNIAUTH_GOOGLE_CLIENT_SECRET"] || ""), type: :string, readonly: true
  field :unityfi_ach_monthly_fee, default: 20.0, type: :decimal

  private
 
    def clear_cache
      puts "===== Cleared Setting Cache ==== "
      # Rails.cache.delete_matched("v1*")
      Setting.clear_cache
    end
end
