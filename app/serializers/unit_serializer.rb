class UnitSerializer < BaseSerializer
	attributes :id, :unit_number, :allocation, :address, :rooms, :bathrooms, :area

	attribute :address do |object|
		full_address object
	end

	attribute :rooms do |object|
		object&.unit_bedrooms
	end

	attribute :allocation do |object|
		object.allocation.round(2) rescue 0.0
	end

	attribute :bathrooms do |object|
		object&.unit_bathrooms
	end

	attribute :area do |object|
		object&.surface_area
	end

	class << self
    private
    def full_address(unit)
      "#{unit.street}, #{unit.city} #{unit.zip_code}".strip
    end
  end
end