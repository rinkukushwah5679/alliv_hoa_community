class UnitFinancial < ApplicationRecord
	enum :frequency, %w(Monthly OneTime)
	belongs_to :unit
	before_create :set_association
	def set_association
		self.association_id = unit.association_id
	end
end
