class OwnershipSerializer < BaseSerializer
	attributes :id, :unit_owner_id, :first_name, :last_name, :phone_number, :email, :is_owner_association_board_member, :is_tenant_occupies_unit, :tenant_first_name, :tenant_last_name, :tenant_phone_number, :tenant_email, :ownership_date_change
	attribute :ownership_date_change do |object|
		{purchase_date: object.date_of_purchase, inheritance_date: object.inheritance_date}
	end
end