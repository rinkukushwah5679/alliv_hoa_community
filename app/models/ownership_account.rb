class OwnershipAccount < ApplicationRecord
	default_scope { order(created_at: :asc) }
	validates :first_name, :last_name, presence: true
	belongs_to :unit#, optional: true
	belongs_to :user, class_name: "User", foreign_key: :unit_owner_id#, optional: true
	before_create :set_association

	def set_association
		self.association_id = unit.association_id
	end
end
