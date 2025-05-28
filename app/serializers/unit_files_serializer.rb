class UnitFilesSerializer < BaseSerializer
  attributes :id, :category_name, :file

  attribute :file do |object|
    if object.document.attached?
      file_url = "https://" + "#{ENV['AWS_BUCKET']}" + ".s3." + "#{ENV['AWS_REGION']}" + ".amazonaws.com/" + "#{object.document.blob.key}"
      file_blob = object.document.blob
      {id: object.id, file_url: file_url, blob: file_blob} rescue nil
    else
      nil
    end
  end

end