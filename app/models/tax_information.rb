class TaxInformation < ApplicationRecord
	validates :tax_payer_id, presence: true
	enum tax_payer_type: { SSN: "SSN", EIN: "EIN"}
end
