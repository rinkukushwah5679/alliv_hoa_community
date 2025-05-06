class Unit < ApplicationRecord
	belongs_to :custom_association, class_name: "Association", foreign_key: :association_id, optional: true
	has_one :ownership_account, dependent: :destroy
	has_one :unit_financial, dependent: :destroy
	has_one :unit_file, dependent: :destroy
	accepts_nested_attributes_for :ownership_account
	accepts_nested_attributes_for :unit_financial
	accepts_nested_attributes_for :unit_file
	has_one_attached :notice_document
end
