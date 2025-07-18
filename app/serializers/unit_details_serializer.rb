class UnitDetailsSerializer < BaseSerializer
	attributes :id, :name, :status, :association_name, :state, :city, :zip_code, :street, :building_no, :floor, :unit_bedrooms, :unit_bathrooms, :surface_area, :unit_number, :address, :bathrooms, :area, :allocation

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
		object.unit_financials.map { |unit_financial| UnitFinancialsSerializer.new(unit_financial).serializable_hash[:data][:attributes] }
	end

	attribute :autopay_status do |object|
		object.autopay_status rescue nil
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

	class << self
    private
    def full_address(unit)
      "#{unit.street}, #{unit.city} #{unit.zip_code}".strip
    end
  end
end