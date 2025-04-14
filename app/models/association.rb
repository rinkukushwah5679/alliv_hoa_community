class Association < ApplicationRecord
	validates :name, presence: true
	has_one :tax_information
end
