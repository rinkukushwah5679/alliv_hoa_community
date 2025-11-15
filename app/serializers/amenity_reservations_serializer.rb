class AmenityReservationsSerializer < BaseSerializer
  attributes :id, :auto_generate_id, :created_date, :association_id, :association_name, :amenity_id, :amenity_name, :serial_number_sku, :quantity

  attribute :created_date do |object|
    object.created_at.strftime("%m/%d/%Y")
  end

  attribute :association_name do |object|
    object.a_name rescue nil
  end

  attribute :amenity_name do |object|
    object.am_amenity_name rescue nil
  end

  attribute :quantity do |object|
    0
  end
end