class UnitFinancial < ApplicationRecord
	enum frequency: %w(Monthly OneTime)
	belongs_to :unit
end
