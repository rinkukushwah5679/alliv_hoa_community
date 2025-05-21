class Association < ApplicationRecord
  validates :name, presence: true
  validates :telephone_no, presence: true
  validates :email, presence: true
  has_one :association_address, dependent: :destroy
  has_many :bank_accounts, as: :bank_accountable, dependent: :destroy
  has_one :association_due, dependent: :destroy
  has_one :association_late_payment_fee, dependent: :destroy
  has_one :tax_information, dependent: :destroy
  has_many :community_association_managers, dependent: :destroy
  has_many :units, dependent: :destroy
  accepts_nested_attributes_for :association_address#, allow_destroy: true
  accepts_nested_attributes_for :association_due
  accepts_nested_attributes_for :association_late_payment_fee
  accepts_nested_attributes_for :tax_information
  accepts_nested_attributes_for :community_association_managers, allow_destroy: true
  accepts_nested_attributes_for :bank_accounts, allow_destroy: true
  accepts_nested_attributes_for :units, allow_destroy: true
  belongs_to :user, class_name: "User", foreign_key: :property_manager_id, optional: true
  validate :validate_units_limit

  def status
    is_active ? "Active" : "Inactive"
  end

  def validate_units_limit
    return unless units.present?

    max_units = user&.number_units_subscribe || 0
    existing_units_count = Unit.joins(:custom_association).where(associations: { property_manager_id: property_manager_id }).count

    total_units = existing_units_count + units.select(&:new_record?).count

    if total_units >= max_units
      errors.add(:base, "You can only create up to #{max_units} units. ass")
    end
  end
end
