class MeetingEventsDetailsSerializer < BaseSerializer
  attributes :id, :auto_generate_id, :created_date, :association_name, :title, :description, :meeting_type, :location, :address, :participants, :host_details, :unit_number, :meeting_date, :start_time, :end_time

  attribute :created_date do |object|
    object.created_at.strftime("%m/%d/%Y")
  end

  attribute :association_name do |object|
    object.a_name rescue nil
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

  attribute :event_attachments do |object|
    data = []
    if object.event_attachments.present?
      data = attachments(object.event_attachments)
    end
    data
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
