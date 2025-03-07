FactoryBot.define do
  factory :bank_account do
    name { Faker::Bank.name }
    description { "MyText" }
    country { Faker::Address.country }
    account_number { Faker::Bank.account_number }
    routing_number { Faker::Bank.routing_number }
    is_active { true }
    created_by { FactoryBot.create(:user).id }
    updated_by { FactoryBot.create(:user).id }
  end
end
