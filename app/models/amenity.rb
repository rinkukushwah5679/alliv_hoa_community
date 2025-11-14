class Amenity < ApplicationRecord
	enum :participants, {"Board Only" => "Board Only", "All Members" => "All Members"}
	belongs_to :custom_association, class_name: "Association", foreign_key: :association_id
	has_many_attached :amenity_attachments
	before_create :set_auto_generate_id
	def set_auto_generate_id
		last_request_id = Amenity.unscoped.maximum(:auto_generate_id) || 1000
		self.auto_generate_id = last_request_id + 1
	end
end