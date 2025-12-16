class WorkOrder < ApplicationRecord
  has_paper_trail :on => [:update]
  default_scope { order(created_at: :asc) }
	validates :subject, presence: true
	enum :work_order_type, ["Maintenance Request", "General Inquiry", "Emergency"]
	enum :schedulling_permission, ["No", "Yes", "NotAplicable"]
	enum :priority, ["Low", "Normal", "High"]
	# enum :work_order_object, ["Unit", "Corridor", "Elevator", "Parking"] #etc
	enum :status, ["Submitted", "Reviewed", "In Progress", "Completed", "Deferred", "Closed"]
  enum :requestor_type, { "Resident" => "unit_owner", "Board Member" => "board_member", "Association" => "association", "Other" => "other"}
	belongs_to :user, class_name: 'User', foreign_key: :user_id
  belongs_to :vendor, class_name: 'User', foreign_key: :vendor_id, optional: true
  belongs_to :category, optional: true
  belongs_to :creator, class_name: "User", foreign_key: :created_by, primary_key: :id, optional: true
  belongs_to :updater, class_name: "User", foreign_key: :updated_by, primary_key: :id, optional: true
  belongs_to :unit#, optional: true
  belongs_to :custom_association, class_name: "Association", foreign_key: :association_id#, optional: true
  has_many_attached :document_files
  has_many :comments, as: :commentable, dependent: :destroy

  def self.data_requestor_type(user_id)
    user = User.find_by(id: user_id)
    return ["Resident"] if user.present? && user.current_role == "Resident"
    return ["Board Member"] if user.present? && user.current_role == "BoardMember"
    return ["Resident", "Board Member", "Association", "Other"] if user.present? && user.current_role == "Vendor"
    return ["Resident", "Association", "Other"] #For System Admin
  end

  # def set_unit_owner_id
  #   unit_owner = unit.ownership_account
  #   if requestor_type.present? && requestor_type == "Association" && requestor_type == "Other"
  #     self.user_id = unit_owner.unit_owner_id
  #   end
  # end
end
