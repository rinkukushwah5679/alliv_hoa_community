class VoteManagementDetailsSerializer < BaseSerializer
  attributes :id, :auto_generate_id, :created_date, :created_by, :association_id, :association_name, :category, :ratification_type, :title, :approval_due_date, :status, :updated_at

  attribute :created_date do |object|
    if object.created_date.present?
      object.created_date
    else
      object.created_at.strftime("%m/%d/%Y")
    end
  end

  attribute :category do |object|
    object.participant_category rescue nil
  end

  attribute :association_name do |object|
    object.a_name rescue nil
  end

  attribute :vote_management_attachments do |object|
    data = []
    if object.vote_management_attachments.present?
      data = attachments(object.vote_management_attachments)
    end
    data
  end

  attribute :created_by do |object|
    # creator = object.creator
    if object.c_id.present?
      {id: object.c_id, first_name: object.c_first_name, last_name: object.c_last_name, full_name: "#{object.c_first_name} #{object.c_last_name}".strip, profile_pic: object.c_profile_pic_url} rescue nil
    else
      nil
    end
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