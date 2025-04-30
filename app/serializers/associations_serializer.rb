class AssociationsSerializer < BaseSerializer
  attributes :id, :name, :telephone_no, :email, :is_active, :web_url, :created_at, :updated_at

  attribute :address do |object|
  	AssociationAddressSerializer.new(object.association_address).serializable_hash[:data][:attributes]
  end

  attribute :dues do |object|
  	object.association_due
  end

  attribute :late_payment_fee do |object|
  	object.association_late_payment_fee
  end

  attribute :tax_identification do |object|
  	object.tax_information
  end

  attribute :community_managers do |object|
  community_managers = object.community_association_managers
  if community_managers.blank?
    []
  else
    community_managers.map do |cm|
      user_data = community_user_data(cm.user)
      { community_manager_id: cm.id, user_data: user_data }
    end
  end
end

  class << self
    private
    def community_user_data(user)
      UserSerializer.new(user).serializable_hash[:data][:attributes]
    end
  end

end