FactoryBot.define do
  factory :amenity do
    auto_generate_id { "" }
    association_id { FactoryBot.create(:association).id }
    amenity_name { "MyString" }
    description { "MyText" }
    serial_number_sku { "MyString" }
    location { "MyString" }
    created_by { FactoryBot.create(:user).id }
    updated_by { FactoryBot.create(:user).id }
  end
end
