class ExpenseThresholdSerializer < BaseSerializer
  attributes :id, :auto_generate_id, :created_date, :association_name, :amount, :approval_type, :status, :updated_at

  attribute :created_date do |object|
    object.created_at.strftime("%m/%d/%Y")
  end

  attribute :association_name do |object|
    object.a_name rescue nil
  end
end
