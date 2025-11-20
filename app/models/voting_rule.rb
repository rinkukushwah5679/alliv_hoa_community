class VotingRule < ApplicationRecord
	enum :participant_category, {"Board Members" => "Board Members", "All Members" => "All Members"}
	enum :ratification_type, {"Simple Majority" => "Simple Majority", "Two-Thirds Majority" => "Two-Thirds Majority", "Three-Fifths Majority" => "Three-Fifths Majority", "Square-Footage" => "Square-Footage"}
	enum :status, {"Active" => "Active", "Inactive" => "Inactive"}
	before_create :set_auto_generate_id
	def set_auto_generate_id
		last_request_id = VotingRule.unscoped.maximum(:auto_generate_id) || 1000
		self.auto_generate_id = last_request_id + 1
	end
end