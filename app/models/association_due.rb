class AssociationDue < ApplicationRecord
	enum :distribution_type, ["Equal Distribution", "Pro Rata Distribution"]
	enum :frequency, %w(Monthly OneTime Annually)
	enum :due_type, {"dues" => "dues", "special_assesment" => "special_assesment", "management_fee" => "management_fee"}
	validates :start_date, presence: true
	# validate :start_date_cannot_be_in_the_past, if: -> { start_date.present? && will_save_change_to_start_date? }

  validates :end_date, presence: true, if: -> { frequency == "Monthly" && (due_type == "special_assesment" || due_type == "management_fee") }

  # Conditional date comparison
  validate :end_date_must_be_after_start_date, if: -> {
    end_date.present? && start_date.present? &&
    frequency == "Monthly" && (due_type == "special_assesment" || due_type == "management_fee")
  }


	def start_date_cannot_be_in_the_past
		if start_date < Date.today
			errors.add(:start_date, "can't be in the past")
			# throw(:abort)
		end
	end

	def end_date_must_be_after_start_date
    if end_date <= start_date
      errors.add(:end_date, "must be after start date")
    end
  end
end
