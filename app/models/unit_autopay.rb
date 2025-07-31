class UnitAutopay < ApplicationRecord
	belongs_to :unit
	belongs_to :user
	belongs_to :payment_method, optional: true
	belongs_to :bank_account, optional: true
	before_create :set_association

	def set_association
		puts "********************************************8"
		self.association_id = unit.association_id
	end
end
