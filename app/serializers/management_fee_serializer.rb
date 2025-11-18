class ManagementFeeSerializer < BaseSerializer
  attributes :id, :description, :amount, :frequency, :start_date, :end_date
end
