class AmenityReservation < ApplicationRecord
	belongs_to :custom_association, class_name: "Association", foreign_key: :association_id
	belongs_to :amenity
	validates :reservation_date, :start_time, :end_time, presence: true
	validate :start_time_should_be_before_end_time
	before_create :set_auto_generate_id
	validate :check_availability_slots

	def set_auto_generate_id
		last_request_id = AmenityReservation.unscoped.maximum(:auto_generate_id) || 1000
		self.auto_generate_id = last_request_id + 1
	end

	private
	# Start time must be before end time
  def start_time_should_be_before_end_time
    return if start_time.blank? || end_time.blank?

    if start_time >= end_time
      errors.add(:start_time, "must be earlier than end time")
    end
  end

  def check_availability_slots
	  return if amenity.blank? || reservation_date.blank? || start_time.blank? || end_time.blank?

	  overlapping_reservations = AmenityReservation
	    .where(amenity_id: amenity_id, reservation_date: reservation_date)
	    .where.not(id: id)
	    .where(
	      "(start_time < ? AND end_time > ?)",
	      end_time, start_time
	    )
	  if overlapping_reservations.count >= amenity.quantity
	    errors.add(:base, "No available slots for this amenity at the selected time.")
	  end
	end

end
