# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
## Ruby
3.3.6

## Rails
7.2.2

## Database
postgres

## For authenticate
use Jwt
## 

##

a.update(
  bank_accounts_attributes: [{
    name: "testing",
    description: "test",
    bank_account_type: "Checking",
    country: "India",
    account_number: "00123456781",
    routing_number: "021000021",
    created_by: "4dc699c3-aad2-454a-9ba0-191e769fb7fe",
    updated_by: "4dc699c3-aad2-454a-9ba0-191e769fb7fe",
  }]
)


---------------------
User.with_role(:PropertyOwner)
  User Load (3.0ms)  SELECT "users".* FROM "users" INNER JOIN "users_roles" ON "users_roles"."user_id" = "users"."id" INNER JOIN "roles" ON "roles"."id" = "users_roles"."role_id" WHERE (((roles.name = $1) AND (roles.resource_type IS NULL) AND (roles.resource_id IS NULL))) /* loading for pp */ LIMIT $2  [[nil, "PropertyOwner"], ["LIMIT", 11]]
 => [#<User id: "87703162-0881-49ca-9e1d-8491d0a7b230", email: [FILTERED], created_at: "2025-05-06 07:33:45.624352000 +0000", updated_at: "2025-05-06 07:33:51.843130000 +0000", first_name: "property", last_name: "owner", username: nil, unit_nickname: nil, gender: nil, dob: nil, stripe_customer_id: "cus_SGCPFTkMx44l1I", stripe_account_id: "acct_1RLg0dQ91cEAajQt", last_request_at: nil, is_active: true, profile_pic_url: "https://alliv-dev.s3.us-east-2.amazonaws.com/i7fl2...", alternate_email: nil, move_in_date: nil, move_out_date: nil, ownership_account_id: nil, created_by: nil, updated_by: nil, send_welcome_email: [FILTERED], is_owner_occupied: true, mailing_preference: "PrimaryAddress", tax_information_id: nil>] 




Test.rb
config.log_level = :debug
config.logger = ActiveSupport::Logger.new(STDOUT)
config.active_support.deprecation = :log