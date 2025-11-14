class AmenitiesDetailsSerializer < BaseSerializer
  attributes :id, :auto_generate_id, :created_date, :association_name, :amenity_name, :description, :serial_number_sku, :location, :participants

  attribute :created_date do |object|
    object.created_at.strftime("%m/%d/%Y")
  end

  attribute :association_name do |object|
    object.a_name rescue nil
  end

  attribute :amenity_attachments do |object|
    data = []
    if object.amenity_attachments.present?
      data = attachments(object.amenity_attachments)
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