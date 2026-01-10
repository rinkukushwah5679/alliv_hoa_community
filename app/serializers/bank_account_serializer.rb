class BankAccountSerializer < BaseSerializer
  attributes :id, :deposit_account_status, :is_primary, :funding_account_id, :is_epay, :stripe_bank_account_id, :available_balance, :formatted_available_balance, :mask, :account_purpose, :name, :description, :bank_account_type, :account_number, :routing_number, :is_active, :is_verified, :created_at, :updated_at

  attribute :formatted_available_balance do |obj|
    format_amount(obj.available_balance) rescue "0.00"
  end

  attribute :deposit_account_status do |obj|
    if obj.is_epay
      "Enabled"
    elsif obj.unityfi_deposit_accounts.present?
      "Application Review"
    else
      "Pending"
    end
  end
end