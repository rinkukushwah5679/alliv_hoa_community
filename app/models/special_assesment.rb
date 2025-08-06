class SpecialAssesment < ApplicationRecord
	enum :distribution_type, { "Equal Distribution" => "Equal Distribution", "Pro Rata Distribution" => "Pro Rata Distribution" }
	enum :frequency, { Monthly: "Monthly", OneTime: "OneTime" }
	# validate :start_date_cannot_be_in_the_past, if: -> { start_date.present? && will_save_change_to_start_date? }
	# validate :end_date_required_if_monthly
  # validate :end_date_must_be_after_start_date, if: -> { start_date.present? && end_date.present? }

	def start_date_cannot_be_in_the_past
		if start_date < Date.today
			errors.add(:start_date, "can't be in the past")
			# throw(:abort)
		end
	end

	def end_date_required_if_monthly
    if frequency == "Monthly" && end_date.blank?
      errors.add(:end_date, "is required when frequency is Monthly")
    end
  end

  def end_date_must_be_after_start_date
    if end_date <= start_date
      errors.add(:end_date, "must be after start date")
    end
  end
end