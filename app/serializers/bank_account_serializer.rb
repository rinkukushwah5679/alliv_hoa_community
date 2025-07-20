class BankAccountSerializer < BaseSerializer
  attributes :id, :stripe_bank_account_id, :account_purpose, :name, :description, :bank_account_type, :account_number, :routing_number, :is_active, :is_verified, :created_at, :updated_at
end