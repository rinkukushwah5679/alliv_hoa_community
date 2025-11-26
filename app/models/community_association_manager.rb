class CommunityAssociationManager < ApplicationRecord
		has_paper_trail :on => [:update]
	  belongs_to :custom_association, class_name: "Association", foreign_key: :association_id, optional: true
	  belongs_to :user
end
