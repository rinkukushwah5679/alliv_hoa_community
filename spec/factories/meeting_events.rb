FactoryBot.define do
  factory :meeting_event do
    auto_generate_id { "" }
    association_id { FactoryBot.create(:association).id }
    created_by { FactoryBot.create(:user).id }
    updated_by { FactoryBot.create(:user).id }
    title { "MyString" }
    description { "MyText" }
    user_id { FactoryBot.create(:user).id }
    unit_number { "MyString" }
    meeting_date { Time.now.to_date + 1.day }
    start_time { "13:00" }
    end_time { "14:45:53" }
    address { "MyString" }
    latitude { "9.99" }
    longitude { "9.99" }
  end
end
