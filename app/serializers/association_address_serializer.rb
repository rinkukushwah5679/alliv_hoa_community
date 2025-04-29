class AssociationAddressSerializer < BaseSerializer
  attributes :id, :city, :state, :postal_code, :address_type, :created_at, :updated_at

  attribute :created_by do |object|
    creator = object.creator
    {id: creator.id, email: creator.email}
  end

  attribute :updated_by do |object|
    updater = object.updater
    {id: updater.id, email: updater.email}
  end
end
