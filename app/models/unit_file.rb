class UnitFile < ApplicationRecord
	has_one_attached :document
	belongs_to :unit
end
