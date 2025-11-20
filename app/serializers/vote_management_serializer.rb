class VoteManagementSerializer < BaseSerializer
  attributes :id, :auto_generate_id, :created_date, :created_by, :association_id, :association_name, :category, :ratification_type, :title, :approval_due_date, :status

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

  attribute :created_by do |object|
    # creator = object.creator
    if object.c_id.present?
      {id: object.c_id, first_name: object.c_first_name, last_name: object.c_last_name, full_name: "#{object.c_first_name} #{object.c_last_name}".strip, profile_pic: object.c_profile_pic_url} rescue nil
    else
      nil
    end
  end

end