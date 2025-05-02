FactoryBot.define do
  factory :community_association_manager do
    user_id { FactoryBot.create(:user).id }
    association_id { FactoryBot.create(:association).id }
    created_by { FactoryBot.create(:user).id }
  end
end
