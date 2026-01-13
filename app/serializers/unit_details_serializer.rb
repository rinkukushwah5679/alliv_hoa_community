class UnitDetailsSerializer < BaseSerializer
	attributes :id, :name, :late_penalty_fee_text, :dues_or_balance, :formatted_dues_or_balance, :status, :association_id, :association_name, :state, :city, :zip_code, :street, :building_no, :floor, :unit_bedrooms, :unit_bathrooms, :surface_area, :unit_number, :address, :bathrooms, :area, :allocation

	attribute :association_name do |object|
		object&.custom_association&.name rescue nil
	end

	attribute :address do |object|
		full_address object
	end

	attribute :bathrooms do |object|
		object&.unit_bathrooms
	end

	attribute :area do |object|
		object&.surface_area
	end

	attribute :allocation do |object|
		object.allocation.round(2) rescue 0.0
	end

	attribute :ownership do |object|
		OwnershipSerializer.new(object.ownership_account).serializable_hash[:data]
	end

	attribute :status do |object|
		object.status rescue nil
	end

	attribute :notice_of_membership do |object|
		if object.notice_document.attached?
			file_url = "https://" + "#{ENV['AWS_BUCKET']}" + ".s3." + "#{ENV['AWS_REGION']}" + ".amazonaws.com/" + "#{object.notice_document.blob.key}"
      file_blob = object.notice_document.blob
		{file: file_url, blob: file_blob} rescue nil
		else
			nil
		end
	end

	attribute :financials do |object|
		# object.unit_financials
		# object.unit_financials.map { |unit_financial| UnitFinancialsSerializer.new(unit_financial).serializable_hash[:data][:attributes] }
		[UnitFinancialsSerializer.new(object.unit_financials.first).serializable_hash[:data][:attributes]]
	end

	attribute :autopay_status do |object|
		begin
			autopay = UnitAutopay.where(unit_id: object.id).last
			if autopay.persisted? && autopay.is_active?
				"Active"
			else
				"InActive"
			end
			# object.autopay_status rescue nil
		rescue => e
			"InActive"
		end
	end

	attribute :attach_files do |object|
    object.unit_files.map { |unit_file| UnitFilesSerializer.new(unit_file).serializable_hash[:data][:attributes] }

		# UnitFilesSerializer.new(object.unit_files).serializable_hash[:data]
    # unit_file = object.unit_file
		# if unit_file && unit_file.document.attached?
		# 	file_url = "https://" + "#{ENV['AWS_BUCKET']}" + ".s3." + "#{ENV['AWS_REGION']}" + ".amazonaws.com/" + "#{unit_file.document.blob.key}"
    #   file_blob = unit_file.document.blob
		# 	{id: unit_file.id, file: file_url, blob: file_blob} rescue nil
		# else
		# 	nil
		# end
	end

	attribute :description do |object|
		object.description
	end

	attribute :dues_or_balance do |object|
		# results = []
		# association = object.custom_association

		# association_units_count = association.units.count
		# convenience_ach_fee_per_unit = association_units_count.positive? ? (Setting.unityfi_ach_monthly_fee.to_f / association_units_count) : 0

		# ownership_account = object.ownership_account
		# unless ownership_account.blank?

		# 	all_dues = association.association_dues
		# 	all_dues.each do |association_due|
		# 		due_type = association_due.due_type
		# 		frequency = association_due.frequency
		# 		next if association_due.blank?

		# 		case due_type
		# 		when "dues"
		# 			results += object.calculate_upcoming_due_entries(association_due, ownership_account, convenience_ach_fee_per_unit.round(2))
		# 		when "special_assesment"
		# 			if frequency == "Monthly"
		# 				results += object.calculate_upcoming_special_assesment_monthly(association_due, ownership_account)
		# 			elsif frequency == "OneTime"
		# 				results += object.calculate_upcoming_special_assesment_onetime(association_due, ownership_account)
		# 			end
		# 		end
		# 	end
		# end
		# results.sum { |r| r[:total_amount].to_f }
		unit_financial = object.unit_financials.first
		amount = unit_financial.present? ? unit_financial.amount : 0.0 rescue 0.0
		amount.to_f
	end

	attribute :formatted_dues_or_balance do |object|
		unit_financial = object.unit_financials.first
		amount = unit_financial.present? ? unit_financial.amount : 0.0 rescue 0.0
		format_amount(amount)
	end

	attribute :late_penalty_fee_text do |object, params|
		if params[:details_page] == "true"
			late_fee = object.custom_association.association_late_payment_fee
			amount = late_fee.present? ? late_fee.amount : 0.0 rescue 0.0
			frequency_days = late_fee.present? ? late_fee.frequency_before_type_cast : 0 rescue 0
			"Payment is due on the 1st of the month. If payment isn't received, a one-time fee of <b>$#{format_amount(amount)}</b> will be charged on the #{frequency_days.ordinalize} of each month."
		else
			nil
		end
	end

	class << self
    private
    def full_address(unit)
      "#{unit.street}, #{unit.city} #{unit.zip_code}".strip
    end
  end
end