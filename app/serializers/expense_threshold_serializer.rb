class ExpenseThresholdSerializer < BaseSerializer
  attributes :id, :auto_generate_id, :created_date, :amount, :approval_type, :status

  attribute :created_date do |object|
    object.created_at.strftime("%m/%d/%Y")
  end
end
