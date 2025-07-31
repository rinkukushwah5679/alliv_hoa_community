class AssociationLatePaymentFee < ApplicationRecord
	# enum frequency: %w(3 7 15) #Frequency: after 3 days, after 7 days, after 15 days (checkboxes)
	# enum :frequency, %w(Monthly OneTime)
	enum :frequency, {"Next days" => 1, "After 3 days" => 3, "After 7 days" => 7, "After 15 days" => 15}
end
