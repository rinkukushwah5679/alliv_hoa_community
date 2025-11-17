class ManagementFeeSerializer < BaseSerializer
  attributes :id, :amount, :frequency, :start_date, :end_date, :title

  attribute :end_date do |object|
    #unclear, have to ask from Kam
    object.end_date
  end

  attribute :title do |object|
    # object.title
    "Hard coded value"
  end
end
