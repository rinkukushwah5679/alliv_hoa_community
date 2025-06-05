class TaxInformation < ApplicationRecord
	validates :tax_payer_id, :tax_payer_type, presence: true
	enum :tax_payer_type, { SSN: "SSN", EIN: "EIN"}
end
