FactoryBot.define do
  factory :vote_management do
    auto_generate_id { "" }
    created_date { "2025-11-19" }
    # association_id { "" }
    # participant_category { "MyString" }
    # ratification_type { "MyString" }
    title { "MyString" }
    description { "MyText" }
    approval_due_date { "2025-11-19" }
    status { "Open" }
    created_by { "" }
    updated_by { "" }
  end
end
