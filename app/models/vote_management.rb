class VoteManagement < ApplicationRecord
	has_paper_trail :on => [:update]
	enum :participant_category, {"Board Members" => "Board Members", "All Members" => "All Members"}
	enum :ratification_type, {"Simple Majority" => "Simple Majority", "Two-Thirds Majority" => "Two-Thirds Majority", "Three-Fifths Majority" => "Three-Fifths Majority", "Square-Footage" => "Square-Footage"}
	enum :status, {"Open" => "Open", "Approved" => "Approved", "Rejected" => "Rejected"}
	enum :meeting_type, {"Annual Meeting" => "Annual Meeting", "Special Meeting" => "Special Meeting", "Board Meeting" => "Board Meeting", "Other" => "Other"}
	belongs_to :creator, class_name: "User", foreign_key: :created_by, optional: true
	belongs_to :custom_association, class_name: "Association", foreign_key: :association_id
	has_many_attached :vote_management_attachments
	has_many :vote_approvals, dependent: :destroy
	validates :title, :ratification_type, presence: true
	belongs_to :voting_rule
	before_create :set_auto_generate_id
	def set_auto_generate_id
		last_request_id = VoteManagement.unscoped.maximum(:auto_generate_id) || 1000
		self.auto_generate_id = last_request_id + 1
	end
end
