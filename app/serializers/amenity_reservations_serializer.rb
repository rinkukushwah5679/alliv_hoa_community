class AmenityReservationsSerializer < BaseSerializer
  attributes :id, :auto_generate_id, :unit_data, :created_date, :association_id, :association_name, :amenity_id, :amenity_name, :reservation_date, :serial_number_sku, :quantity

  attribute :unit_data do |object|
    unit = nil
    units = Unit.joins(:ownership_account).where(
      ownership_accounts: { unit_owner_id: object.user_id }
    )
    unit = units.last if units.present?
    if unit.present?
      {id: unit.id, unit_name: unit.name, unit_number: unit.unit_number}
    else
      nil
    end
  end
  attribute :created_date do |object|
    object.created_at.strftime("%m/%d/%Y")
  end

  attribute :association_name do |object|
    object.a_name rescue nil
  end

  attribute :amenity_name do |object|
    object.am_amenity_name rescue nil
  end

  attribute :start_time do |obj|
    obj.start_time.strftime("%H:%M") rescue nil
  end

  attribute :end_time do |obj|
    obj.end_time.strftime("%H:%M") rescue nil
  end

  attribute :quantity do |object|
    # 0
    object.am_quantity rescue 0
  end
end