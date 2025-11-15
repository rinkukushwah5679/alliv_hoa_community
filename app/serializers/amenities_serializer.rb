class AmenitiesSerializer < BaseSerializer
  attributes :id, :auto_generate_id, :created_date, :association_name, :amenity_name, :serial_number_sku, :quantity

  attribute :created_date do |object|
    object.created_at.strftime("%m/%d/%Y")
  end

  attribute :association_name do |object|
    object.custom_association.name rescue nil
  end

  attribute :quantity do |object|
    object.amenity_reservations.count rescue 0
  end
end