class AssociationDue < ApplicationRecord
	enum :distribution_type, ["Equal Distribution", "Pro Rata Distribution"]
	enum :frequency, %w(Monthly OneTime)
	validates :start_date, presence: true
	validate :start_date_cannot_be_in_the_past, if: -> { start_date.present? && will_save_change_to_start_date? }

	def start_date_cannot_be_in_the_past
		if start_date < Date.today
			errors.add(:start_date, "can't be in the past")
			# throw(:abort)
		end
	end
end
