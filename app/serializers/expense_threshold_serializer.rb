class ExpenseThresholdSerializer < BaseSerializer
  attributes :id, :auto_generate_id, :created_date, :association_name, :amount, :formatted_amount, :approval_type, :status, :updated_at

  attribute :created_date do |object|
    object.created_at.strftime("%m/%d/%Y")
  end

  attribute :formatted_amount do |object|
    format_amount(object.amount) rescue "0.00"
  end

  attribute :association_name do |object|
    object.a_name rescue nil
  end
end
