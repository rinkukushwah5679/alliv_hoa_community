class WalkthroughDetailsSerializer < BaseSerializer
	attributes :id

	attribute :association_name do |ob|
		ob&.custom_association&.name rescue nil
	end

	attributes :property_manager_name do |ob|
		manager = ob.user
		# ob&.user&.full_name rescue nil
		{id: manager.id, full_name: "#{manager.first_name} #{manager.last_name}".strip, profile_pic: manager.profile_pic_url} rescue nil
	end

	attribute :facade do |object|
		object&.facade&.body rescue nil
	end

	attribute :facade_attachments do |object|
		data = []
    if object.facade_attachments.present?
      data = attachments(object.facade_attachments)
    end
    data
	end

	attribute :balcony do |object|
		object&.balcony&.body rescue nil
	end

	attribute :balcony_attachments do |object|
		data = []
    if object.balcony_attachments.present?
      data = attachments(object.balcony_attachments)
    end
    data
	end

	attribute :window_door_screens do |object|
		object&.window_door_screens&.body rescue nil
	end

	attribute :window_door_screens_attachments do |object|
		data = []
    if object.window_door_screens_attachments.present?
      data = attachments(object.window_door_screens_attachments)
    end
    data
	end


	attribute :balcony_door_frame do |object|
		object&.balcony_door_frame&.body rescue nil
	end

	attribute :balcony_door_frame_attachments do |object|
		data = []
    if object.balcony_door_frame_attachments.present?
      data = attachments(object.balcony_door_frame_attachments)
    end
    data
	end

	attribute :front_doors do |object|
		object&.front_doors&.body rescue nil
	end

	attribute :front_doors_attachments do |object|
		data = []
    if object.front_doors_attachments.present?
      data = attachments(object.front_doors_attachments)
    end
    data
	end

	attribute :landscaping do |object|
		object&.landscaping&.body rescue nil
	end

	attribute :landscaping_attachments do |object|
		data = []
    if object.landscaping_attachments.present?
      data = attachments(object.landscaping_attachments)
    end
    data
	end

	attribute :sliding do |object|
		object&.sliding&.body rescue nil
	end

	attribute :sliding_attachments do |object|
		data = []
    if object.sliding_attachments.present?
      data = attachments(object.sliding_attachments)
    end
    data
	end

	attribute :exterior_stairwells do |object|
		object&.exterior_stairwells&.body rescue nil
	end

	attribute :exterior_stairwells_attachments do |object|
		data = []
    if object.exterior_stairwells_attachments.present?
      data = attachments(object.exterior_stairwells_attachments)
    end
    data
	end

	attribute :dryer_vent_covers do |object|
		object&.dryer_vent_covers&.body rescue nil
	end

	attribute :dryer_vent_covers_attachments do |object|
		data = []
    if object.dryer_vent_covers_attachments.present?
      data = attachments(object.dryer_vent_covers_attachments)
    end
    data
	end

	attribute :rodents_critters do |object|
		object&.rodents_critters&.body rescue nil
	end

	attribute :rodents_critters_attachments do |object|
		data = []
    if object.rodents_critters_attachments.present?
      data = attachments(object.rodents_critters_attachments)
    end
    data
	end

	attribute :gutters do |object|
		object&.gutters&.body rescue nil
	end

	attribute :gutters_attachments do |object|
		data = []
    if object.gutters_attachments.present?
      data = attachments(object.gutters_attachments)
    end
    data
	end

	attribute :roof do |object|
		object&.roof&.body rescue nil
	end

	attribute :roof_attachments do |object|
		data = []
    if object.roof_attachments.present?
      data = attachments(object.roof_attachments)
    end
    data
	end

	attribute :lights do |object|
		object&.lights&.body rescue nil
	end

	attribute :lights_attachments do |object|
		data = []
    if object.lights_attachments.present?
      data = attachments(object.lights_attachments)
    end
    data
	end

	attribute :spigots do |object|
		object&.spigots&.body rescue nil
	end

	attribute :spigots_attachments do |object|
		data = []
    if object.spigots_attachments.present?
      data = attachments(object.spigots_attachments)
    end
    data
	end

	attribute :sprinkler_systems do |object|
		object&.sprinkler_systems&.body rescue nil
	end

	attribute :sprinkler_systems_attachments do |object|
		data = []
    if object.sprinkler_systems_attachments.present?
      data = attachments(object.sprinkler_systems_attachments)
    end
    data
	end

	attribute :mailboxes do |object|
		object&.mailboxes&.body rescue nil
	end

	attribute :mailboxes_attachments do |object|
		data = []
    if object.mailboxes_attachments.present?
      data = attachments(object.mailboxes_attachments)
    end
    data
	end

	attribute :trash_bins do |object|
		object&.trash_bins&.body rescue nil
	end

	attribute :trash_bins_attachments do |object|
		data = []
    if object.trash_bins_attachments.present?
      data = attachments(object.trash_bins_attachments)
    end
    data
	end

	attribute :leaks do |object|
		object&.leaks&.body rescue nil
	end

	attribute :leaks_attachments do |object|
		data = []
    if object.leaks_attachments.present?
      data = attachments(object.leaks_attachments)
    end
    data
	end

	attribute :unit_numbers do |object|
		object&.unit_numbers&.body rescue nil
	end

	attribute :unit_numbers_attachments do |object|
		data = []
    if object.unit_numbers_attachments.present?
      data = attachments(object.unit_numbers_attachments)
    end
    data
	end

	attribute :gate_doors do |object|
		object&.gate_doors&.body rescue nil
	end

	attribute :gate_doors_attachments do |object|
		data = []
    if object.gate_doors_attachments.present?
      data = attachments(object.gate_doors_attachments)
    end
    data
	end

	attribute :decoration do |object|
		object&.decoration&.body rescue nil
	end

	attribute :decoration_attachments do |object|
		data = []
    if object.decoration_attachments.present?
      data = attachments(object.decoration_attachments)
    end
    data
	end

	attribute :internet_phone_lines do |object|
		object&.internet_phone_lines&.body rescue nil
	end

	attribute :internet_phone_lines_attachments do |object|
		data = []
    if object.internet_phone_lines_attachments.present?
      data = attachments(object.internet_phone_lines_attachments)
    end
    data
	end

	attribute :vandalization do |object|
		object&.vandalization&.body rescue nil
	end

	attribute :vandalization_attachments do |object|
		data = []
    if object.vandalization_attachments.present?
      data = attachments(object.vandalization_attachments)
    end
    data
	end

	attribute :vehicles do |object|
		object&.vehicles&.body rescue nil
	end

	attribute :vehicles_attachments do |object|
		data = []
    if object.vehicles_attachments.present?
      data = attachments(object.vehicles_attachments)
    end
    data
	end

	attribute :facade_enhancements do |object|
		object&.facade_enhancements&.body rescue nil
	end

	attribute :facade_enhancements_attachments do |object|
		data = []
    if object.facade_enhancements_attachments.present?
      data = attachments(object.facade_enhancements_attachments)
    end
    data
	end

	attribute :lendscaping_enhancements do |object|
		object&.lendscaping_enhancements&.body rescue nil
	end

	attribute :lendscaping_enhancements_attachments do |object|
		data = []
    if object.lendscaping_enhancements_attachments.present?
      data = attachments(object.lendscaping_enhancements_attachments)
    end
    data
	end

	attribute :other_improvements do |object|
		object&.other_improvements&.body rescue nil
	end

	attribute :other_improvements_attachments do |object|
		data = []
    if object.other_improvements_attachments.present?
      data = attachments(object.other_improvements_attachments)
    end
    data
	end

	attribute :roof_improvements do |object|
		object&.roof_improvements&.body rescue nil
	end

	attribute :roof_improvements_attachments do |object|
		data = []
    if object.roof_improvements_attachments.present?
      data = attachments(object.roof_improvements_attachments)
    end
    data
	end

	attribute :miscellaneous do |object|
		object&.miscellaneous&.body rescue nil
	end

	attribute :miscellaneous_attachments do |object|
		data = []
    if object.miscellaneous_attachments.present?
      data = attachments(object.miscellaneous_attachments)
    end
    data
	end

	attribute :scores do |object|
		object&.scores rescue nil
	end

	attribute :average_score do |object|
		object&.health_score
	end

	class << self
    private
    def attachments(attachments)
    	data = []
    	attachments.each do |file|
        file_url = "https://" + "#{ENV['AWS_BUCKET']}" + ".s3." + "#{ENV['AWS_REGION']}" + ".amazonaws.com/" + "#{file.blob.key}"
        blob = file.blob
        data << {file_id: file.id, file_url: file_url} rescue nil
      end
      data
    end
  end
end