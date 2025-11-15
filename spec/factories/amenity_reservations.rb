FactoryBot.define do
  factory :amenity_reservation do
    auto_generate_id { "" }
    association_id { "" }
    user_id { "" }
    amenity_id { "MyString" }
    description { "MyText" }
    serial_number_sku { "MyString" }
    location { "MyString" }
    reservation_date { "2025-11-15" }
    start_time { "2025-11-15 13:39:08" }
    end_time { "2025-11-15 13:39:08" }
    created_by { "" }
    updated_by { "" }
  end
end
