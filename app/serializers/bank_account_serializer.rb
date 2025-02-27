class BankAccountSerializer < BaseSerializer
  attributes :id, :name, :description, :bank_account_type, :country, :account_number, :routing_number, :is_active, :created_at, :updated_at
end