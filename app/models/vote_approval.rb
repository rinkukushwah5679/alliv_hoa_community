class VoteApproval < ApplicationRecord
	has_paper_trail :on => [:update]
	enum :status, {"Approved" => "Approved", "Rejected" => "Rejected"}
	# before_create :set_association
	belongs_to :vote_management
	belongs_to :user

	# def set_association
	# 	self.association_id = vote_management.association_id
	# end
	after_save :update_vote_management_status
	private
	def update_vote_management_status
    vm = self.vote_management

    total_votes = vm.vote_approvals.count
    approved_count = vm.vote_approvals.where(status: "Approved").count
    rejected_count = total_votes - approved_count

    approved_percentage = if total_votes > 0
                            (approved_count.to_f / total_votes) * 100
                          else
                            0
                          end

    required_percentage = case vm.ratification_type
                          when "Simple Majority"
                            51
                          when "Three-Fifths Majority"
                            60
                          when "Two-Thirds Majority"
                            66.7
                          when "Square-Footage"
                            75
                          else
                            0
                          end

    # Final Decision
    if approved_percentage >= required_percentage
      vm.update(status: "Approved")
    else
      vm.update(status: "Rejected")
    end
  end
end
