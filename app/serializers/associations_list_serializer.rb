class AssociationsListSerializer < BaseSerializer
  attributes :id, :location_user_id, :association_dues, :name, :status, :units_number, :address, :managers, :created_at, :updated_at

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
    # object.association_due&.amount rescue "0.0"
    results = []
    late_fee_config = object.association_late_payment_fee
    dues = object.association_dues

    total_units = object.units.count
    convenience_fee = Setting.unityfi_ach_monthly_fee.to_f # assuming column
    convenience_ach_fee_per_unit = total_units > 0 ? (convenience_fee / total_units).round(2) : 0

    object.units.includes(:ownership_account).each do |unit|
      ownership_account = unit.ownership_account
      next if ownership_account.blank?

      dues.each do |association_due|
        next if association_due.blank?

        case association_due.due_type
        when "dues"
          next unless association_due.frequency == "Monthly"

          # Same logic as before for Monthly Dues
          results += unit.calculate_due_entries(association_due, ownership_account, late_fee_config, convenience_ach_fee_per_unit.round(2))
        when "special_assesment"
          if association_due.frequency == "Monthly"
            results += unit.calculate_special_assesment_monthly(association_due, ownership_account, late_fee_config)
          elsif association_due.frequency == "OneTime"
            results += unit.calculate_special_assesment_onetime(association_due, ownership_account, late_fee_config)
          end
        end
      end
    end
    grouped = results.group_by { |r| r[:unit_id] }

    final_units = grouped.map do |unit_id, entries|
      {
        overdue_amount: entries.sum { |e| e[:total_dues].to_f }
      }
    end
    final_units.sum { |r| r[:overdue_amount] }
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