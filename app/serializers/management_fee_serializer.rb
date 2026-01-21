class ManagementFeeSerializer < BaseSerializer
  attributes :id, :description, :amount, :formatted_amount, :frequency, :start_date, :end_date
  attribute :formatted_amount do |object|
    format_amount(object.amount) rescue "0.00"
  end
end
