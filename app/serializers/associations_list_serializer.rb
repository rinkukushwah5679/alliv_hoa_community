class AssociationsListSerializer < BaseSerializer
  attributes :id, :location_user_id, :name, :status, :units_number, :address, :managers, :created_at, :updated_at

  attribute :address do |object|
    unless object.association_address
      nil
    else
      AssociationAddressSerializer.new(object.association_address).serializable_hash[:data][:attributes]
    end
  end

  attribute :managers do |object|
    community_managers = object.community_association_managers
    if community_managers.blank?
      []
    else
      community_managers.map do |com|
        begin
          user_data = community_user_data(com.user)
          { community_manager_id: com.id, user_data: user_data }
        rescue StandardError => e
          []
        end
      end
    end
  end

  attribute :units_number do |object|
    object.units.count
  end

  attribute :association_dues do |object|
    object.association_due&.amount rescue "0.0"
  end

  attribute :status do |object|
    object&.status
  end

  class << self
    private
    def community_user_data(user)
      UserSerializer.new(user).serializable_hash[:data][:attributes]
    end
  end
end