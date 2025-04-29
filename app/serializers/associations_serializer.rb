class AssociationsSerializer < BaseSerializer
  attributes :id, :name, :telephone_no, :email, :is_active, :web_url, :created_at, :updated_at

  attribute :addresses do |object|
  	AssociationAddressSerializer.new(object.addresses).serializable_hash
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
  	UserSerializer.new(User.where(id: object.community_association_managers.map(&:user_id)))
  end

  # class << self
  #     private

end