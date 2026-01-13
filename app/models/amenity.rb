class Amenity < ApplicationRecord
	has_paper_trail :on => [:update]
	enum :participants, {"Board Only" => "Board Only", "All Members" => "All Members"}
	validates :amenity_name, presence: true, length: { maximum: 250, message: "can't be longer than 250 characters" }
	# validates :quantity, presence: true, numericality: { greater_than: 0 }
	belongs_to :custom_association, class_name: "Association", foreign_key: :association_id
	has_many_attached :amenity_attachments
	has_many :amenity_reservations, dependent: :destroy
	before_create :set_auto_generate_id
	def set_auto_generate_id
		last_request_id = Amenity.unscoped.maximum(:auto_generate_id) || 1000
		self.auto_generate_id = last_request_id + 1
	end
end