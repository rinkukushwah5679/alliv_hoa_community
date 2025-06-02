class WalkthroughsSerializer < BaseSerializer
	attributes :id, :association_name, :property_manager_name, :date_submitted, :submitted_by, :heath_score

	attribute :association_name do |ob|
		ob&.custom_association&.name rescue nil
	end

	attributes :property_manager_name do |ob|
		ob&.user&.full_name rescue nil
	end

	attribute :date_submitted do |ob|
		ob.created_at
	end

	attribute :submitted_by do |object|
    creator = object.creator
    {id: creator.id, full_name: "#{creator.first_name} #{creator.last_name}".strip, profile_pic: creator.profile_pic_url} rescue nil
  end
end