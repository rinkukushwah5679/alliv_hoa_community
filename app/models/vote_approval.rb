class VoteApproval < ApplicationRecord
	has_paper_trail :on => [:update]
	enum :status, {"Approved" => "Approved", "Rejected" => "Rejected"}
	# before_create :set_association
	belongs_to :vote_management
	belongs_to :user

	# def set_association
	# 	self.association_id = vote_management.association_id
	# end
end
