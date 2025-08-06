class SpecialAssesmentsSerializer < BaseSerializer
  attributes :id, :amount, :type, :frequency, :start_date, :end_date, :title

  attribute :type do |object|
    object.distribution_type rescue nil
  end

  attribute :end_date do |object|
    #unclear, have to ask from Kam
    object.end_date
  end

  attribute :title do |object|
    # object.title
    "Hard coded value"
  end
end
