class BankAccount < ApplicationRecord
  default_scope { order(created_at: :asc) }
	validates :name, presence: true
	enum :bank_account_type, { Checking: "Checking", Savings: "Savings" }
	belongs_to :creator, class_name: "User", foreign_key: :created_by, optional: true#, primary_key: :id
  belongs_to :updater, class_name: "User", foreign_key: :updated_by, optional: true#, primary_key: :id
  # validates :account_number, uniqueness: { scope: :routing_number, case_sensitive: false, message: lambda{|x, y| "#{y[:value]} is already present" }}
  # validates :account_number, uniqueness: { case_sensitive: false, message: lambda{|x, y| "#{y[:value]} is already present" }}
  # validates :account_number, uniqueness: true
  belongs_to :bank_accountable, polymorphic: true, optional: true
  belongs_to :user, optional: true
  enum :account_purpose, {operating: "operating", reserve: "reserve"}
end