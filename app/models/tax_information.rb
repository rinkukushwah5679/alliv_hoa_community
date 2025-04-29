class TaxInformation < ApplicationRecord
	enum tax_payer_type: { SSN: "SSN", EIN: "EIN"}
end
