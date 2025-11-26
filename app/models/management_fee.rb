class ManagementFee < ApplicationRecord
  has_paper_trail :on => [:update]
	enum :frequency, {"Monthly" => "Monthly", "Annually" => "Annually"}
	validates :end_date, presence: true, if: -> { frequency == "Monthly" }
	validate :end_date_must_be_after_start_date, if: -> {
    end_date.present? && start_date.present? &&
    frequency == "Monthly"
  }
  def end_date_must_be_after_start_date
    if end_date <= start_date
      errors.add(:end_date, "must be after start date")
    end
  end
end
