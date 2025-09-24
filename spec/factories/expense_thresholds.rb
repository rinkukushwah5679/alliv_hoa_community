FactoryBot.define do
  factory :expense_threshold do
    association_id { FactoryBot.create(:association).id }
    amount { "9.99" }
    status { "Active" }
    approval_type { "Simple Majority" }
  end
end
