class AmenityReservationDetailsSerializer < BaseSerializer
  attributes :id, :auto_generate_id, :created_date, :association_id, :association_name, :amenity_id, :amenity_name, :description, :serial_number_sku, :location, :reservation_date

  attribute :created_date do |object|
    object.created_at.strftime("%m/%d/%Y")
  end

  attribute :association_name do |object|
    object.a_name rescue nil
  end

  attribute :amenity_name do |object|
    object.am_amenity_name rescue nil
  end

  attribute :start_time do |obj|
    obj.start_time.strftime("%I:%M%P") rescue nil
  end

  attribute :end_time do |obj|
    obj.end_time.strftime("%I:%M%P") rescue nil
  end

  attribute :amenity_attachments do |object|
    data = []
    if object.amenity.amenity_attachments.present?
      data = attachments(object.amenity.amenity_attachments)
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
        data << {file_id: file.id, file_url: file_url, file_name: blob['filename'], file_type: blob['content_type'], file_size: blob['byte_size']/1024.0} rescue nil
      end
      data
    end
  end
end