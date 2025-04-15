# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2025_03_10_061725) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounting_entities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "accounting_entity_type", default: 0
    t.string "href"
    t.uuid "unit_id"
    t.uuid "accounting_entitieable_id"
    t.string "accounting_entitieable_type"
    t.uuid "bank_account_id"
    t.uuid "association_id"
    t.uuid "created_by"
    t.uuid "updated_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["association_id"], name: "index_accounting_entities_on_association_id"
    t.index ["bank_account_id"], name: "index_accounting_entities_on_bank_account_id"
    t.index ["created_by"], name: "index_accounting_entities_on_created_by"
    t.index ["unit_id"], name: "index_accounting_entities_on_unit_id"
    t.index ["updated_by"], name: "index_accounting_entities_on_updated_by"
  end

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "addresses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "address_line1", null: false
    t.string "address_line2"
    t.string "address_line3"
    t.string "city"
    t.string "state"
    t.string "postal_code"
    t.string "country", null: false
    t.uuid "addressable_id"
    t.string "addressable_type"
    t.integer "address_type", default: 0
    t.uuid "created_by"
    t.uuid "updated_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by"], name: "index_addresses_on_created_by"
    t.index ["updated_by"], name: "index_addresses_on_updated_by"
  end

  create_table "appliances", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "make"
    t.string "model_no"
    t.text "description"
    t.date "install_date"
    t.date "warranty_end_date"
    t.uuid "association_id"
    t.uuid "unit_id"
    t.uuid "created_by"
    t.uuid "updated_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["association_id"], name: "index_appliances_on_association_id"
    t.index ["created_by"], name: "index_appliances_on_created_by"
    t.index ["unit_id"], name: "index_appliances_on_unit_id"
    t.index ["updated_by"], name: "index_appliances_on_updated_by"
  end

  create_table "architectural_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "association_id"
    t.uuid "ownership_account_id"
    t.string "name"
    t.datetime "submitted_date_time"
    t.string "status", default: "New"
    t.string "decision", default: "Pending"
    t.uuid "created_by"
    t.uuid "updated_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["association_id"], name: "index_architectural_requests_on_association_id"
    t.index ["created_by"], name: "index_architectural_requests_on_created_by"
    t.index ["ownership_account_id"], name: "index_architectural_requests_on_ownership_account_id"
    t.index ["updated_by"], name: "index_architectural_requests_on_updated_by"
  end

  create_table "associations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.boolean "is_active", default: true
    t.integer "reserve"
    t.text "description"
    t.integer "year_built"
    t.uuid "property_manager_id"
    t.uuid "operating_bank_account_id"
    t.string "url"
    t.uuid "created_by"
    t.uuid "updated_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by"], name: "index_associations_on_created_by"
    t.index ["operating_bank_account_id"], name: "index_associations_on_operating_bank_account_id"
    t.index ["property_manager_id"], name: "index_associations_on_property_manager_id"
    t.index ["updated_by"], name: "index_associations_on_updated_by"
  end

  create_table "bank_account_tags", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "bank_account_id"
    t.uuid "bank_account_tagable_id"
    t.string "bank_account_tagable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bank_accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "bank_account_type"
    t.string "country"
    t.string "account_number"
    t.string "routing_number"
    t.string "bank_accountable_id"
    t.string "bank_accountable_type"
    t.boolean "is_active", default: true
    t.uuid "created_by"
    t.uuid "updated_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by"], name: "index_bank_accounts_on_created_by"
    t.index ["updated_by"], name: "index_bank_accounts_on_updated_by"
  end

  create_table "bill_files", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "bill_id"
    t.string "title"
    t.string "physical_file_name"
    t.decimal "size"
    t.string "content_type"
    t.datetime "uploaded_date_time"
    t.uuid "association_id"
    t.uuid "created_by"
    t.uuid "updated_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["association_id"], name: "index_bill_files_on_association_id"
    t.index ["bill_id"], name: "index_bill_files_on_bill_id"
    t.index ["created_by"], name: "index_bill_files_on_created_by"
    t.index ["updated_by"], name: "index_bill_files_on_updated_by"
  end

  create_table "bills", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.date "date"
    t.string "due_date"
    t.string "memo"
    t.uuid "vendor_id"
    t.uuid "work_order_id"
    t.string "reference_number"
    t.uuid "association_id"
    t.uuid "created_by"
    t.uuid "updated_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["association_id"], name: "index_bills_on_association_id"
    t.index ["created_by"], name: "index_bills_on_created_by"
    t.index ["updated_by"], name: "index_bills_on_updated_by"
    t.index ["vendor_id"], name: "index_bills_on_vendor_id"
    t.index ["work_order_id"], name: "index_bills_on_work_order_id"
  end

  create_table "board_member_terms", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "association_owner_id"
    t.string "board_position_type"
    t.date "start_date"
    t.date "end_date"
    t.uuid "association_id"
    t.uuid "created_by"
    t.uuid "updated_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["association_id"], name: "index_board_member_terms_on_association_id"
    t.index ["association_owner_id"], name: "index_board_member_terms_on_association_owner_id"
    t.index ["created_by"], name: "index_board_member_terms_on_created_by"
    t.index ["updated_by"], name: "index_board_member_terms_on_updated_by"
  end

  create_table "budget_details", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "budget_id"
    t.uuid "general_ledger_account_id"
    t.decimal "january_amount", default: "0.0"
    t.decimal "february_amount", default: "0.0"
    t.decimal "march_amount", default: "0.0"
    t.decimal "april_amount", default: "0.0"
    t.decimal "may_amount", default: "0.0"
    t.decimal "june_amount", default: "0.0"
    t.decimal "july_amount", default: "0.0"
    t.decimal "august_amount", default: "0.0"
    t.decimal "september_amount", default: "0.0"
    t.decimal "october_amount", default: "0.0"
    t.decimal "november_amount", default: "0.0"
    t.decimal "december_amount", default: "0.0"
    t.uuid "association_id"
    t.uuid "created_by"
    t.uuid "updated_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["association_id"], name: "index_budget_details_on_association_id"
    t.index ["budget_id"], name: "index_budget_details_on_budget_id"
    t.index ["created_by"], name: "index_budget_details_on_created_by"
    t.index ["general_ledger_account_id"], name: "index_budget_details_on_general_ledger_account_id"
    t.index ["updated_by"], name: "index_budget_details_on_updated_by"
  end

  create_table "budgets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.uuid "property_id"
    t.integer "start_month", default: 0
    t.integer "fiscal_year"
    t.uuid "association_id"
    t.uuid "created_by"
    t.uuid "updated_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["association_id"], name: "index_budgets_on_association_id"
    t.index ["created_by"], name: "index_budgets_on_created_by"
    t.index ["property_id"], name: "index_budgets_on_property_id"
    t.index ["updated_by"], name: "index_budgets_on_updated_by"
  end

  create_table "business_details", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "busi_name"
    t.string "first_name"
    t.string "last_name"
    t.string "office_address"
    t.string "phone"
    t.string "email"
    t.string "fein_or_tin_number"
    t.uuid "user_id"
    t.uuid "association_id"
    t.uuid "created_by"
    t.uuid "updated_by"
    t.string "business_logo_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "check_files", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "bank_account_id"
    t.uuid "check_id"
    t.string "title"
    t.string "physical_file_name"
    t.decimal "size"
    t.string "content_type"
    t.datetime "uploaded_date_time"
    t.uuid "association_id"
    t.uuid "created_by"
    t.uuid "updated_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["association_id"], name: "index_check_files_on_association_id"
    t.index ["bank_account_id"], name: "index_check_files_on_bank_account_id"
    t.index ["check_id"], name: "index_check_files_on_check_id"
    t.index ["created_by"], name: "index_check_files_on_created_by"
    t.index ["updated_by"], name: "index_check_files_on_updated_by"
  end

  create_table "check_printing_infos", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "bank_account_id"
    t.boolean "enable_remote_check_printing", default: true
    t.boolean "enable_local_check_printing", default: true
    t.integer "check_layout_type", default: 0
    t.string "signature_heading"
    t.string "fractional_number"
    t.string "bank_information_line1"
    t.string "bank_information_line2"
    t.string "bank_information_line3"
    t.string "bank_information_line4"
    t.string "bank_information_line5"
    t.string "company_information_line1"
    t.string "company_information_line2"
    t.string "company_information_line3"
    t.string "company_information_line4"
    t.string "company_information_line5"
    t.uuid "association_id"
    t.uuid "created_by"
    t.uuid "updated_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["association_id"], name: "index_check_printing_infos_on_association_id"
    t.index ["bank_account_id"], name: "index_check_printing_infos_on_bank_account_id"
    t.index ["created_by"], name: "index_check_printing_infos_on_created_by"
    t.index ["updated_by"], name: "index_check_printing_infos_on_updated_by"
  end

  create_table "checks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "payee_id"
    t.integer "payee_type", default: 0
    t.string "payee_herf"
    t.string "check_number"
    t.date "entry_date"
    t.string "memo"
    t.decimal "total_amount", default: "0.0"
    t.uuid "bank_account_id"
    t.uuid "association_id"
    t.uuid "created_by"
    t.uuid "updated_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["association_id"], name: "index_checks_on_association_id"
    t.index ["bank_account_id"], name: "index_checks_on_bank_account_id"
    t.index ["created_by"], name: "index_checks_on_created_by"
    t.index ["payee_id"], name: "index_checks_on_payee_id"
    t.index ["updated_by"], name: "index_checks_on_updated_by"
  end

  create_table "deposits", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "bank_account_id"
    t.date "entry_date"
    t.string "memo"
    t.string "payment_transaction_ids", default: [], array: true
    t.uuid "association_id"
    t.uuid "created_by"
    t.uuid "updated_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["association_id"], name: "index_deposits_on_association_id"
    t.index ["bank_account_id"], name: "index_deposits_on_bank_account_id"
    t.index ["created_by"], name: "index_deposits_on_created_by"
    t.index ["updated_by"], name: "index_deposits_on_updated_by"
  end

  create_table "e_pay_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "eft_payment_enabled", default: true
    t.boolean "credit_card_payment_enabled", default: true
    t.boolean "offline_payment_display_info_resident_center", default: true
    t.boolean "offline_payment_display_company_address", default: true
    t.string "offline_payment_instructions"
    t.uuid "association_id"
    t.uuid "created_by"
    t.uuid "updated_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["association_id"], name: "index_e_pay_settings_on_association_id"
    t.index ["created_by"], name: "index_e_pay_settings_on_created_by"
    t.index ["updated_by"], name: "index_e_pay_settings_on_updated_by"
  end

  create_table "electronic_payments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "bank_account_id"
    t.integer "debit_transaction_limit", default: 0
    t.integer "credit_transaction_limit", default: 0
    t.integer "debit_monthly_limit", default: 0
    t.integer "credit_monthly_limit", default: 0
    t.decimal "resident_eft_convience_fee_amount", default: "0.0"
    t.decimal "resident_credit_card_convenience_fee_amount", default: "0.0"
    t.decimal "credit_card_service_fee_percentage", default: "0.0"
    t.boolean "is_credit_card_service_fee_paid_by_resident", default: true
    t.uuid "association_id"
    t.uuid "created_by"
    t.uuid "updated_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["association_id"], name: "index_electronic_payments_on_association_id"
    t.index ["bank_account_id"], name: "index_electronic_payments_on_bank_account_id"
    t.index ["created_by"], name: "index_electronic_payments_on_created_by"
    t.index ["updated_by"], name: "index_electronic_payments_on_updated_by"
  end

  create_table "emergency_contacts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "relationship"
    t.string "phone_number"
    t.string "email"
    t.uuid "user_id"
    t.uuid "created_by"
    t.uuid "updated_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by"], name: "index_emergency_contacts_on_created_by"
    t.index ["updated_by"], name: "index_emergency_contacts_on_updated_by"
    t.index ["user_id"], name: "index_emergency_contacts_on_user_id"
  end

  create_table "general_ledger_accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "bank_account_id"
    t.string "account_number"
    t.string "name"
    t.text "description"
    t.string "type"
    t.string "sub_ype"
    t.boolean "is_default_gl_account", default: true
    t.string "default_account_name"
    t.boolean "is_contra_account", default: true
    t.boolean "is_bank_account", default: true
    t.string "cash_flow_classification"
    t.boolean "exclude_from_cash_balances", default: true
    t.boolean "is_active", default: true
    t.uuid "parent_gl_account_id"
    t.uuid "association_id"
    t.uuid "created_by"
    t.uuid "updated_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["association_id"], name: "index_general_ledger_accounts_on_association_id"
    t.index ["bank_account_id"], name: "index_general_ledger_accounts_on_bank_account_id"
    t.index ["created_by"], name: "index_general_ledger_accounts_on_created_by"
    t.index ["parent_gl_account_id"], name: "index_general_ledger_accounts_on_parent_gl_account_id"
    t.index ["updated_by"], name: "index_general_ledger_accounts_on_updated_by"
  end

  create_table "lines", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "general_ledger_account_id"
    t.string "memo"
    t.string "reference_number"
    t.decimal "amount", default: "0.0"
    t.uuid "lineable_id"
    t.string "lineable_type"
    t.uuid "association_id"
    t.uuid "created_by"
    t.uuid "updated_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["association_id"], name: "index_lines_on_association_id"
    t.index ["created_by"], name: "index_lines_on_created_by"
    t.index ["general_ledger_account_id"], name: "index_lines_on_general_ledger_account_id"
    t.index ["updated_by"], name: "index_lines_on_updated_by"
  end

  create_table "meter_details", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "unit_id"
    t.uuid "meter_reading_id"
    t.uuid "association_id"
    t.integer "previous_meter_reading_value"
    t.integer "current_reading_value"
    t.uuid "created_by"
    t.uuid "updated_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["association_id"], name: "index_meter_details_on_association_id"
    t.index ["created_by"], name: "index_meter_details_on_created_by"
    t.index ["meter_reading_id"], name: "index_meter_details_on_meter_reading_id"
    t.index ["unit_id"], name: "index_meter_details_on_unit_id"
    t.index ["updated_by"], name: "index_meter_details_on_updated_by"
  end

  create_table "meter_readings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "association_id"
    t.date "reading_date"
    t.string "meter_type"
    t.uuid "created_by"
    t.uuid "updated_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["association_id"], name: "index_meter_readings_on_association_id"
    t.index ["created_by"], name: "index_meter_readings_on_created_by"
    t.index ["updated_by"], name: "index_meter_readings_on_updated_by"
  end

  create_table "notes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "note"
    t.uuid "noteable_id"
    t.string "noteable_type"
    t.uuid "association_id"
    t.uuid "created_by"
    t.uuid "updated_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by"], name: "index_notes_on_created_by"
    t.index ["updated_by"], name: "index_notes_on_updated_by"
  end

  create_table "ownership_accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "unit_id"
    t.date "date_of_purchase"
    t.decimal "association_fee", default: "0.0"
    t.string "recurring_frequency"
    t.string "association_owner_ids", default: [], array: true
    t.boolean "send_welcome_email", default: true
    t.boolean "replace_existing_ownership_account", default: true
    t.uuid "created_by"
    t.uuid "updated_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by"], name: "index_ownership_accounts_on_created_by"
    t.index ["unit_id"], name: "index_ownership_accounts_on_unit_id"
    t.index ["updated_by"], name: "index_ownership_accounts_on_updated_by"
  end

  create_table "phone_numbers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "home"
    t.string "work"
    t.string "mobile"
    t.string "fax"
    t.uuid "phone_numberable_id"
    t.string "phone_numberable_type"
    t.uuid "created_by"
    t.uuid "updated_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by"], name: "index_phone_numbers_on_created_by"
    t.index ["updated_by"], name: "index_phone_numbers_on_updated_by"
  end

  create_table "quick_deposits", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.date "entry_date"
    t.uuid "general_ledger_account_id"
    t.decimal "amount", default: "0.0"
    t.string "memo"
    t.uuid "bank_account_id"
    t.uuid "association_id"
    t.uuid "created_by"
    t.uuid "updated_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["association_id"], name: "index_quick_deposits_on_association_id"
    t.index ["bank_account_id"], name: "index_quick_deposits_on_bank_account_id"
    t.index ["created_by"], name: "index_quick_deposits_on_created_by"
    t.index ["general_ledger_account_id"], name: "index_quick_deposits_on_general_ledger_account_id"
    t.index ["updated_by"], name: "index_quick_deposits_on_updated_by"
  end

  create_table "reconciliations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "bank_account_id"
    t.date "statement_ending_date"
    t.decimal "total_checks_and_withdrawals", default: "0.0"
    t.decimal "total_deposits_and_additions", default: "0.0"
    t.decimal "ending_balance", default: "0.0"
    t.uuid "association_id"
    t.uuid "created_by"
    t.uuid "updated_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["association_id"], name: "index_reconciliations_on_association_id"
    t.index ["bank_account_id"], name: "index_reconciliations_on_bank_account_id"
    t.index ["created_by"], name: "index_reconciliations_on_created_by"
    t.index ["updated_by"], name: "index_reconciliations_on_updated_by"
  end

  create_table "roles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_roles_on_name"
  end

  create_table "service_histories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "service_type"
    t.date "date"
    t.string "details"
    t.uuid "appliance_id"
    t.uuid "created_by"
    t.uuid "updated_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["appliance_id"], name: "index_service_histories_on_appliance_id"
    t.index ["created_by"], name: "index_service_histories_on_created_by"
    t.index ["updated_by"], name: "index_service_histories_on_updated_by"
  end

  create_table "tax_informations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "text_payer_id", null: false
    t.string "tax_payer_type"
    t.string "tax_payer_name1", limit: 40
    t.string "tax_payer_name2", limit: 40
    t.uuid "association_id"
    t.uuid "created_by"
    t.uuid "updated_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["association_id"], name: "index_tax_informations_on_association_id"
    t.index ["created_by"], name: "index_tax_informations_on_created_by"
    t.index ["updated_by"], name: "index_tax_informations_on_updated_by"
  end

  create_table "transfers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "bank_account_id"
    t.date "entry_date"
    t.decimal "total_amount", default: "0.0"
    t.string "memo"
    t.uuid "association_id"
    t.uuid "created_by"
    t.uuid "updated_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["association_id"], name: "index_transfers_on_association_id"
    t.index ["bank_account_id"], name: "index_transfers_on_bank_account_id"
    t.index ["created_by"], name: "index_transfers_on_created_by"
    t.index ["updated_by"], name: "index_transfers_on_updated_by"
  end

  create_table "units", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "unit_number"
    t.string "name"
    t.integer "unit_size"
    t.string "unit_bedrooms"
    t.string "unit_bathrooms"
    t.uuid "association_id"
    t.uuid "created_by"
    t.uuid "updated_by"
    t.string "resident_or_owner"
    t.string "occupancy_status"
    t.string "occupancy_type"
    t.string "state"
    t.decimal "amount", default: "0.0"
    t.uuid "category_id"
    t.integer "repeat_every"
    t.datetime "starting_on"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["association_id"], name: "index_units_on_association_id"
    t.index ["category_id"], name: "index_units_on_category_id"
    t.index ["created_by"], name: "index_units_on_created_by"
    t.index ["updated_by"], name: "index_units_on_updated_by"
  end

  create_table "user_roles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "role_id"
    t.uuid "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["user_id"], name: "index_user_roles_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "username"
    t.string "unit_nickname"
    t.string "gender"
    t.date "dob"
    t.string "stripe_customer_id"
    t.string "stripe_account_id"
    t.datetime "last_request_at"
    t.boolean "is_active", default: false
    t.string "profile_pic_url"
    t.string "alternate_email"
    t.date "move_in_date"
    t.date "move_out_date"
    t.uuid "ownership_account_id"
    t.uuid "created_by"
    t.uuid "updated_by"
    t.boolean "send_welcome_email", default: true
    t.boolean "is_owner_occupied", default: true
    t.string "mailing_preference", default: "PrimaryAddress"
    t.uuid "tax_information_id"
    t.index ["created_by"], name: "index_users_on_created_by"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["updated_by"], name: "index_users_on_updated_by"
  end

  create_table "withdrawals", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "bank_account_id"
    t.date "entry_date"
    t.uuid "general_ledger_account_id"
    t.decimal "amount", default: "0.0"
    t.string "memo"
    t.uuid "association_id"
    t.uuid "created_by"
    t.uuid "updated_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["association_id"], name: "index_withdrawals_on_association_id"
    t.index ["bank_account_id"], name: "index_withdrawals_on_bank_account_id"
    t.index ["created_by"], name: "index_withdrawals_on_created_by"
    t.index ["general_ledger_account_id"], name: "index_withdrawals_on_general_ledger_account_id"
    t.index ["updated_by"], name: "index_withdrawals_on_updated_by"
  end

  create_table "work_orders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id"
    t.integer "work_order_type"
    t.uuid "category_id"
    t.string "subject"
    t.text "description"
    t.uuid "vendor_id"
    t.uuid "association_id"
    t.integer "schedulling_permission", default: 0
    t.boolean "is_open", default: true
    t.uuid "created_by"
    t.uuid "updated_by"
    t.integer "work_order_object"
    t.uuid "unit_id"
    t.integer "status"
    t.integer "priority", default: 0
    t.date "due_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_change_status_date_time"
    t.bigint "request_id"
    t.datetime "deleted_at"
    t.index ["association_id"], name: "index_work_orders_on_association_id"
    t.index ["category_id"], name: "index_work_orders_on_category_id"
    t.index ["created_by"], name: "index_work_orders_on_created_by"
    t.index ["deleted_at"], name: "index_work_orders_on_deleted_at"
    t.index ["unit_id"], name: "index_work_orders_on_unit_id"
    t.index ["updated_by"], name: "index_work_orders_on_updated_by"
    t.index ["user_id"], name: "index_work_orders_on_user_id"
    t.index ["vendor_id"], name: "index_work_orders_on_vendor_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
