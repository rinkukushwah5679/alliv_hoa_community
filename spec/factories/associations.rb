FactoryBot.define do
  factory :association do
    name { "MyString" }
    is_active { false }
    reserve { 1 }
    description { "MyText" }
    year_built { 1 }
    property_manager_id { "" }
    operating_bank_account_id { "" }
    web_url { "MyString" }
    created_by { "" }
    updated_by { "" }
    telephone_no {Faker::PhoneNumber.phone_number}
    email { Faker::Internet.email }
  end
end
