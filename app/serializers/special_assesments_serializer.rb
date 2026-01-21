class SpecialAssesmentsSerializer < BaseSerializer
  attributes :id, :amount, :formatted_amount, :type, :frequency, :start_date, :end_date, :title

  attribute :type do |object|
    object.distribution_type rescue nil
  end

  attribute :formatted_amount do |object|
    format_amount(object.amount) rescue "0.00"
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
