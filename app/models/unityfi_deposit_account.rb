class UnityfiDepositAccount < ApplicationRecord
  has_paper_trail :on => [:update]
	ONLY_STRING_REGEX = /\A[a-zA-Z\s]+\z/
	ONLY_NUMBER_REGEX = /\A\d+\z/
	validates :legal_business_name, :association_name, :processing_type, :hoa_address_street_address, :hoa_address_line2, :hoa_address_city, :hoa_address_state_or_region, :hoa_address_zip_code, :hoa_address_country, :contact_details_webside, :contact_details_phone, :deposit_account_routing_number, :deposit_account_number, :deposit_account_ein, :primary_contact_first_name, :primary_contact_last_name, :primary_contact_signer_ssn, :primary_contact_email, presence: true
  has_one_attached :signers_drivers_license
  has_one_attached :voided_check_bank_latter_bank_signature_card
  has_one_attached :ssn_or_ein_latter
  has_one_attached :article_organization_incorporation
  has_one_attached :additional_signer_drivers_license
  # enum :processing_type, {"Credit Card" => "Credit Card", "ACH" => "ACH", "Credit Card And ACH" => "Credit Card And ACH"}
  validate :attachments_presence

  validate :routing_number_should_not_have_alphabets, :account_number_should_not_have_alphabets, :ein_should_not_have_alphabets

  validate :signers_drivers_license_file_check_size, :voided_check_bank_latter_bank_signature_card_check_size, :ssn_or_ein_latter_check_size, :article_organization_incorporation_check_size, :additional_signer_drivers_license_check_size

  validate :drivers_license_file_type, :voided_check_bank_latter_bank_signature_card_file_type, :ssn_or_ein_latter_file_type, :article_organization_incorporation_file_type, :additional_signer_drivers_license_file_type

  validates :hoa_address_zip_code, :contact_details_phone, :primary_contact_signer_ssn, :additional_signer_ssn,format: {with: ONLY_NUMBER_REGEX, message: "only numbers are allowed"}, allow_blank: true

  validates :legal_business_name, :hoa_address_city, :hoa_address_state_or_region, :hoa_address_country, :primary_contact_first_name, :primary_contact_last_name, :additional_signers_location, :additional_signer_first_name, :additional_signer_last_name, format: {with: ONLY_STRING_REGEX, message: "only alphabets are allowed"}, allow_blank: true

  private

  def drivers_license_file_type
	  if signers_drivers_license.attached? &&
	     !signers_drivers_license.content_type.in?(%w[image/jpeg image/png image/webp application/pdf])
	    errors.add(:signers_drivers_license, "must be JPG, PNG, or PDF")
	  end
	end

	def voided_check_bank_latter_bank_signature_card_file_type
	  if voided_check_bank_latter_bank_signature_card.attached? &&
	     !voided_check_bank_latter_bank_signature_card.content_type.in?(%w[image/jpeg image/png image/webp application/pdf])
	    errors.add("Voided check Bank Letter or Bank Signature Card", "must be JPG, PNG, or PDF")
	  end
	end

	def ssn_or_ein_latter_file_type
	  if ssn_or_ein_latter.attached? &&
	     !ssn_or_ein_latter.content_type.in?(%w[image/jpeg image/png image/webp application/pdf])
	    errors.add(:ssn_or_ein_latter, "must be JPG, PNG, or PDF")
	  end
	end

	def article_organization_incorporation_file_type
	  if article_organization_incorporation.attached? &&
	     !article_organization_incorporation.content_type.in?(%w[image/jpeg image/png image/webp application/pdf])
	    errors.add("Article of organization or Article of Incorporation", "must be JPG, PNG, or PDF")
	  end
	end

	def additional_signer_drivers_license_file_type
	  if additional_signer_drivers_license.attached? &&
	     !additional_signer_drivers_license.content_type.in?(%w[image/jpeg image/png image/webp application/pdf])
	    errors.add(:additional_signer_drivers_license, "must be JPG, PNG, or PDF")
	  end
	end

  def attachments_presence
    validate_attachment(:signers_drivers_license, "Signer's Drivers License is required")
    validate_attachment(:voided_check_bank_latter_bank_signature_card, "Voided check Bank Letter or Bank Signature Card is required")
    validate_attachment(:ssn_or_ein_latter, "SSN or EIN Letter is required")
    validate_attachment(:article_organization_incorporation, "Article of organization or Article of Incorporation is required")
    # validate_attachment(:additional_signer_drivers_license, "Additional signer driver license is required")
  end

  def signers_drivers_license_file_check_size
  	if signers_drivers_license.attached? &&
			signers_drivers_license.blob.byte_size > 6.megabytes
			errors.add(:signers_drivers_license, "size must be less than 6MB")
		end
  end

  def voided_check_bank_latter_bank_signature_card_check_size
  	if voided_check_bank_latter_bank_signature_card.attached? &&
			voided_check_bank_latter_bank_signature_card.blob.byte_size > 6.megabytes
			errors.add("Voided check Bank Letter or Bank Signature Card", "size must be less than 6MB")
		end
  end

  def ssn_or_ein_latter_check_size
  	if ssn_or_ein_latter.attached? &&
			ssn_or_ein_latter.blob.byte_size > 6.megabytes
			errors.add("SSN or EIN Letter", "size must be less than 6MB")
		end
  end

  def article_organization_incorporation_check_size
  	if article_organization_incorporation.attached? &&
			article_organization_incorporation.blob.byte_size > 6.megabytes
			errors.add("Article of organization or Article of Incorporation", "size must be less than 6MB")
		end
  end

  def additional_signer_drivers_license_check_size
  	if additional_signer_drivers_license.attached? &&
			additional_signer_drivers_license.blob.byte_size > 6.megabytes
			errors.add(:additional_signer_drivers_license, "size must be less than 6MB")
		end
  end

  def validate_attachment(name, message)
    errors.add(:base, message) unless send(name).attached?
  end

  def routing_number_should_not_have_alphabets
    raw_value = deposit_account_routing_number_before_type_cast
    return if raw_value.blank?

    unless raw_value.to_s.match?(/\A\d+\z/)
      errors.add(:base, "Alphabet not allow into Routing number")
    end
  end

  def account_number_should_not_have_alphabets
    raw_value = deposit_account_number_before_type_cast
    return if raw_value.blank?

    unless raw_value.to_s.match?(/\A\d+\z/)
      errors.add(:base, "Alphabet not allow into Account number")
    end
  end

  def ein_should_not_have_alphabets
    raw_value = deposit_account_ein_before_type_cast
    return if raw_value.blank?

    unless raw_value.to_s.match?(/\A\d+\z/)
      errors.add(:base, "Alphabet not allow into EIN")
    end
  end
end