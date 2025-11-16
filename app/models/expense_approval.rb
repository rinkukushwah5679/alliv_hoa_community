class ExpenseApproval < ApplicationRecord
	has_paper_trail :on => [:update]
	validates :title, presence: true
	has_many_attached :expense_approval_attachments
	belongs_to :custom_association, class_name: "Association", foreign_key: :association_id
	belongs_to :user
	enum :status, { "Routed for Approval" => "Routed for Approval", "Approved" => "Approved", "Rejected" => "Rejected"}
	has_many :comments, as: :commentable, dependent: :destroy
	before_create :set_auto_generate_id
	def set_auto_generate_id
		last_request_id = ExpenseApproval.unscoped.maximum(:auto_generate_id) || 1000
		self.auto_generate_id = last_request_id + 1
	end
end
