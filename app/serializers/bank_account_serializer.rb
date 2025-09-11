class BankAccountSerializer < BaseSerializer
  attributes :id, :funding_account_id, :is_epay, :stripe_bank_account_id, :available_balance, :mask, :account_purpose, :name, :description, :bank_account_type, :account_number, :routing_number, :is_active, :is_verified, :created_at, :updated_at
end