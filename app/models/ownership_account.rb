class OwnershipAccount < ApplicationRecord
	has_paper_trail :on => [:update]
	default_scope { order(created_at: :asc) }
	validates :first_name, :last_name, presence: true
	validates :date_of_purchase, presence: true
	belongs_to :unit#, optional: true
	belongs_to :user, class_name: "User", foreign_key: :unit_owner_id#, optional: true
	before_create :set_association
	before_update :disable_previous_owner_autopay, if: :will_save_change_to_unit_owner_id?

	def set_association
		self.association_id = unit.association_id
	end

	private

	def disable_previous_owner_autopay
    previous_owner_id, new_owner_id = unit_owner_id_change
    return if previous_owner_id.blank?

    autopay = UnitAutopay.find_by(unit_id: unit_id, user_id: previous_owner_id)
    if autopay&.is_active?
      autopay.update(is_active: false)
    end
  end
end
