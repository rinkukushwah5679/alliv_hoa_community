class AssociationDue < ApplicationRecord
	enum distribution_type: ["Equal Distribution", "Pro Rata Distribution"]
	enum frequency: %w(Monthly OneTime)
end
