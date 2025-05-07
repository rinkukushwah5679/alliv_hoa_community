FactoryBot.define do
  factory :unit_file do
    unit_id { FactoryBot.create(:unit).id }
    created_by { FactoryBot.create(:user).id }
    updated_by { FactoryBot.create(:user).id }
  end
end
