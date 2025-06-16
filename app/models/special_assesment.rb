class SpecialAssesment < ApplicationRecord
	enum :distribution_type, { "Equal Distribution" => "Equal Distribution", "Pro Rata Distribution" => "Pro Rata Distribution" }
	enum :frequency, { Monthly: "Monthly", OneTime: "OneTime" }
	validate :start_date_cannot_be_in_the_past, if: -> { start_date.present? }

	def start_date_cannot_be_in_the_past
		if start_date < Date.today
			errors.add(:start_date, "can't be in the past")
			# throw(:abort)
		end
	end
end