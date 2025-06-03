class Walkthrough < ApplicationRecord

	has_rich_text :facade
	has_many_attached :facade_attachments

	has_rich_text :balcony
	has_many_attached :balcony_attachments

	has_rich_text :window_door_screens
	has_many_attached :window_door_screens_attachments

	has_rich_text :balcony_door_frame
	has_many_attached :balcony_door_frame_attachments

	has_rich_text :front_doors
	has_many_attached :front_doors_attachments

	has_rich_text :landscaping
	has_many_attached :landscaping_attachments

	has_rich_text :sliding
	has_many_attached :sliding_attachments

	has_rich_text :exterior_stairwells
	has_many_attached :exterior_stairwells_attachments

	has_rich_text :dryer_vent_covers
	has_many_attached :dryer_vent_covers_attachments

	has_rich_text :rodents_critters
	has_many_attached :rodents_critters_attachments

	has_rich_text :gutters
	has_many_attached :gutters_attachments

	has_rich_text :roof
	has_many_attached :roof_attachments

	has_rich_text :lights
	has_many_attached :lights_attachments

	has_rich_text :spigots
	has_many_attached :spigots_attachments

	has_rich_text :sprinkler_systems
	has_many_attached :sprinkler_systems_attachments

	has_rich_text :mailboxes
	has_many_attached :mailboxes_attachments

	has_rich_text :trash_bins
	has_many_attached :trash_bins_attachments

	has_rich_text :leaks
	has_many_attached :leaks_attachments

	has_rich_text :unit_numbers
	has_many_attached :unit_numbers_attachments

	has_rich_text :gate_doors
	has_many_attached :gate_doors_attachments

	has_rich_text :decoration
	has_many_attached :decoration_attachments

	has_rich_text :internet_phone_lines
	has_many_attached :internet_phone_lines_attachments

	has_rich_text :vandalization
	has_many_attached :vandalization_attachments

	has_rich_text :vehicles
	has_many_attached :vehicles_attachments

	has_rich_text :facade_enhancements
	has_many_attached :facade_enhancements_attachments

	has_rich_text :lendscaping_enhancements
	has_many_attached :lendscaping_enhancements_attachments

	has_rich_text :other_improvements
	has_many_attached :other_improvements_attachments

	has_rich_text :roof_improvements
	has_many_attached :roof_improvements_attachments

	has_rich_text :miscellaneous
	has_many_attached :miscellaneous_attachments

	# has_rich_text :scores
	# has_many_attached :scores_attachments

	belongs_to :custom_association, class_name: "Association", foreign_key: :association_id, optional: true
	belongs_to :user #Manager
	belongs_to :creator, class_name: "User", foreign_key: :created_by, optional: true
  belongs_to :updater, class_name: "User", foreign_key: :updated_by, optional: true
end
