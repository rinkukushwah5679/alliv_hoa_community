class ExpenseThreshold < ApplicationRecord
	enum :approval_type, {"Simple Majority" => "Simple Majority", "Two-Thirds Majority" => "Two-Thirds Majority", "Three-Fifths Majority" => "Three-Fifths Majority"}
	enum :status, {"Active" => "Active", "Inactive" => "Inactive"}
	before_create :set_auto_generate_id
	belongs_to :custom_association, class_name: "Association", foreign_key: :association_id#, optional: true

	def set_auto_generate_id
		last_request_id = ExpenseThreshold.unscoped.maximum(:auto_generate_id) || 1000
		self.auto_generate_id = last_request_id + 1
	end
end
