class UserSerializer < BaseSerializer
  attributes :id, :first_name, :last_name, :full_name, :profile_pic

  attribute :full_name do |object|
    object.full_name
  end

  attribute :profile_pic do |object|
    object.profile_pic_url
  end
end
