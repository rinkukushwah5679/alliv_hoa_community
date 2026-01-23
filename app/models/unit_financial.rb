class UnitFinancial < ApplicationRecord
	default_scope { order(created_at: :asc) }
	validates :amount, numericality: { greater_than: 0 }
	enum :frequency, %w(Monthly OneTime)
	belongs_to :unit
	before_create :set_association
	def set_association
		self.association_id = unit.association_id
	end
end
