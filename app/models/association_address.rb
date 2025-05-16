class AssociationAddress < ApplicationRecord
	# belongs_to :custom_association, class_name: "Association", foreign_key: :association_id, optional: true
	belongs_to :creator, class_name: "User", foreign_key: :created_by, primary_key: :id, optional: true
  belongs_to :updater, class_name: "User", foreign_key: :updated_by, primary_key: :id, optional: true
end
