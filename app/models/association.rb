class Association < ApplicationRecord
	validates :name, presence: true
	validates :telephone_no, presence: true
	validates :email, presence: true
  has_one :association_address, dependent: :destroy
  has_one :association_due, dependent: :destroy
  has_one :association_late_payment_fee, dependent: :destroy
  has_one :tax_information, dependent: :destroy
	has_many :community_association_managers, dependent: :destroy
  accepts_nested_attributes_for :association_address#, allow_destroy: true
  accepts_nested_attributes_for :association_due
  accepts_nested_attributes_for :association_late_payment_fee
  accepts_nested_attributes_for :tax_information
  accepts_nested_attributes_for :community_association_managers, allow_destroy: true
end
