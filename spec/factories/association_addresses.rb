FactoryBot.define do
  factory :association_address do
    street { "MyString" }
    building_no { 1 }
    zip_code { "MyString" }
    state { "MyString" }
    city { "MyString" }
    association_id { FactoryBot.create(:association).id }
    created_by { FactoryBot.create(:user).id }
    updated_by { FactoryBot.create(:user).id }
  end
end
