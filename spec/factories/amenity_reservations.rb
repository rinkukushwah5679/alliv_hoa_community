FactoryBot.define do
  factory :amenity_reservation do
    auto_generate_id { "" }
    user_id { "" }
    amenity_id { "MyString" }
    description { "MyText" }
    serial_number_sku { "MyString" }
    location { "MyString" }
    reservation_date { "2025-11-15" }
    created_by { "" }
    updated_by { "" }
  end
end
