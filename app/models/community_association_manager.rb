class CommunityAssociationManager < ApplicationRecord
	  belongs_to :custom_association, class_name: "Association", foreign_key: :association_id, optional: true
	  belongs_to :user
end
