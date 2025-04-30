class AssociationAddress < ApplicationRecord
	belongs_to :creator, class_name: "User", foreign_key: :created_by, primary_key: :id
  belongs_to :updater, class_name: "User", foreign_key: :updated_by, primary_key: :id
end
