class MeetingEventsSerializer < BaseSerializer
  attributes :id, :auto_generate_id, :created_date, :association_name, :title, :meeting_type, :meeting_link, :location, :host_details, :unit_number, :meeting_date, :start_time, :end_time

  attribute :created_date do |object|
    object.created_at.strftime("%m/%d/%Y")
  end

  attribute :association_name do |object|
    object.custom_association.name rescue nil
  end

  attribute :host_details do |object|
    user = object.user
    if user.present?
      {id: user.id, full_name: "#{user.first_name} #{user.last_name}".strip, profile_pic: user.profile_pic_url} rescue nil
    else
      nil
    end
  end

  attribute :start_time do |obj|
    obj.start_time.strftime("%I:%M%P") rescue nil
  end

  attribute :end_time do |obj|
    obj.end_time.strftime("%I:%M%P") rescue nil
  end
end
