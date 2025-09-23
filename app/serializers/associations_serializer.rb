class AssociationsSerializer < BaseSerializer
  attributes :id, :location_user_id, :is_payout_enabled, :name, :telephone_no, :email, :is_active, :status, :web_url, :created_at, :updated_at

  attribute :address do |object|
    unless object.association_address
      nil
    else
      AssociationAddressSerializer.new(object.association_address).serializable_hash[:data][:attributes]
    end
  end

  attribute :bank_accounts do |object|
    BankAccountSerializer.new(object.bank_accounts).serializable_hash[:data]
  end

  attribute :dues do |object|
    object.association_due
  end

  attribute :late_payment_fee do |object|
  	object.association_late_payment_fee
  end

  attribute :special_assesments do |object|
    SpecialAssesmentsSerializer.new(object.special_assesments).serializable_hash[:data] rescue []
    # object.special_assesments rescue []
  end

  attribute :expense_thresholds do |object|
    ExpenseThresholdSerializer.new(object.expense_thresholds).serializable_hash[:data] rescue []
  end

  attribute :tax_identification do |object|
  	object.tax_information
  end

  attribute :community_managers do |object|
    community_managers = object.community_association_managers
    if community_managers.blank?
      []
    else
      community_managers.map do |com|
        user_data = community_user_data(com.user)
        { community_manager_id: com.id, user_data: user_data }
      end
    end
  end

  attribute :units do |object|
    UnitSerializer.new(object.units).serializable_hash[:data]
  end

  class << self
    private
    def community_user_data(user)
      UserSerializer.new(user).serializable_hash[:data][:attributes]
    end
  end

end