class HistoriesSerializer < BaseSerializer
  attributes :id, :date, :event_type, :made_by

  attribute :date do |object|
    object.created_at
  end

  attribute :event_type do |object|
    object.object_changes
  end

  attribute :made_by do |object|
    user = User.find_by(id: object.whodunnit)
    if user.present?
      {id: user.id, full_name: "#{user.first_name} #{user.last_name}".strip, profile_pic: user.profile_pic_url} rescue nil
    else
      nil
    end
  end
end
