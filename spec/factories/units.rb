FactoryBot.define do
  factory :unit do
    unit_number { "MyString" }
    name { "MyString" }
    unit_size { 1 }
    unit_bedrooms { "MyString" }
    unit_bathrooms { "MyString" }
    association_id { FactoryBot.create(:association).id }
    created_by { FactoryBot.create(:user).id }
    updated_by { FactoryBot.create(:user).id }
    resident_or_owner { "MyString" }
    occupancy_status { "MyString" }
    occupancy_type { "MyString" }
    state { "MyString" }
    amount { "9.99" }
    category_id { "MyString" }
    repeat_every { 1 }
    starting_on { "2025-01-08 14:57:56" }
    description { "MyText" }
  end
end
