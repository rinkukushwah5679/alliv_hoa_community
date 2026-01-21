class UnitFinancialsSerializer < BaseSerializer
  attributes :id, :amount, :formatted_amount, :frequency, :start_date, :unit_id, :association_id, :created_at, :updated_at
  attribute :formatted_amount do |object|
    format_amount(object.amount) rescue "0.00"
  end
end