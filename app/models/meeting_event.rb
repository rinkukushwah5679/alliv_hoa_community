class MeetingEvent < ApplicationRecord
	enum :meeting_type, {"Board Meeting" => "Board Meeting", "Annual Meeting" => "Annual Meeting", "Special Board Meeting" => "Special Board Meeting", "Special Member Meeting" => "Special Member Meeting", "General Member Meeting" => "General Member Meeting", "General Board Meeting" => "General Board Meeting", "General Meeting" => "General Meeting"}
	enum :location, {"In-Person" => "In-Person", "Teleconference" => "Teleconference"}
	enum :participants, {"Board Only" => "Board Only", "All Members" => "All Members"}
	belongs_to :custom_association, class_name: "Association", foreign_key: :association_id
  belongs_to :user, optional: true
  validate :user_must_exist
	before_create :set_auto_generate_id
  has_many_attached :event_attachments
	validate :meeting_date_cannot_be_in_past
	validate :start_time_should_be_before_end_time

	def set_auto_generate_id
		last_request_id = MeetingEvent.unscoped.maximum(:auto_generate_id) || 1000
		self.auto_generate_id = last_request_id + 1
	end


  private
  def user_must_exist
    errors.add(:base, "Host must exist") if user.blank?
  end

  # Past date not allowed
  def meeting_date_cannot_be_in_past
    return if meeting_date.blank?

    if meeting_date.to_date < Date.current
      errors.add(:meeting_date, "can't be in the past")
    end
  end

  # Start time must be before end time
  def start_time_should_be_before_end_time
    return if start_time.blank? || end_time.blank?

    if start_time >= end_time
      errors.add(:start_time, "must be earlier than end time")
    end
  end
end
