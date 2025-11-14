class Association < ApplicationRecord
  acts_as_paranoid
  # attr_accessor :special_assesments
  default_scope { order(created_at: :desc) }
  validates :name, presence: true
  # validates :telephone_no, presence: true
  # validates :email, presence: true
  has_one :association_address, dependent: :destroy
  has_many :bank_accounts, as: :bank_accountable, dependent: :destroy
  has_many :association_dues, dependent: :destroy
  has_one :association_late_payment_fee, dependent: :destroy
  has_one :tax_information, dependent: :destroy
  has_many :community_association_managers, dependent: :destroy
  has_many :units, dependent: :destroy
  # has_many :special_assesments, dependent: :destroy
  accepts_nested_attributes_for :association_address#, allow_destroy: true
  accepts_nested_attributes_for :association_dues, allow_destroy: true
  accepts_nested_attributes_for :association_late_payment_fee
  accepts_nested_attributes_for :tax_information
  accepts_nested_attributes_for :community_association_managers, allow_destroy: true
  accepts_nested_attributes_for :bank_accounts, allow_destroy: true
  accepts_nested_attributes_for :units, allow_destroy: true
  # accepts_nested_attributes_for :special_assesments, allow_destroy: true
  belongs_to :user, class_name: "User", foreign_key: :property_manager_id, optional: true
  has_many :walkthroughs, dependent: :destroy
  has_many :expense_thresholds, dependent: :destroy
  accepts_nested_attributes_for :expense_thresholds, allow_destroy: true
  has_many :meeting_events, dependent: :destroy
  has_many :announcements, dependent: :destroy
  has_many :amenities, dependent: :destroy
  has_many :violations, dependent: :destroy
  validate :validate_units_limit
  enum :status, { Active: "Active", InActive: "InActive"}
  before_save :set_is_active_flag, if: :will_save_change_to_status?
  after_create :create_stripe_account_id, :create_user_on_unityfi

  # def status
  #   is_active ? "Active" : "Inactive"
  # end

  # def special_assesments_attributes=(attributes)
  #   attributes.values.each do |special_attrs|
  #     if special_attrs[:id].present?
  #       # Update existing record
  #       special = self.association_dues.find_by(id: special_attrs[:id], association_id: self.id, due_type: "special_assesment")
  #       special.update(special_attrs) if special
  #     else
  #       # Create new record
  #       self.association_dues.create(special_attrs)
  #     end
  #   end
  # end


  def set_is_active_flag
    if status == "Active"
      self.is_active = true
    else
      self.is_active = false
    end
  end

  def validate_units_limit
    return unless units.present?
    # max_units = user&.number_units_subscribe || 0
    subs = user.subscriptions.where(status: "active").last
    unless subs.present?
      errors.add(:base, "You have no active subscription.")
      return
    end

    if subs.end_date.blank? || subs.end_date <= Time.current
      errors.add(:base, "Your subscription has expired.")
      return
    end
    # max_units = user&.number_units_subscribe || 0
    max_units = subs&.units || 0
    existing_units_count = Unit.joins(:custom_association).where(associations: { property_manager_id: property_manager_id }).count

    total_units = existing_units_count + units.select(&:new_record?).count

    if total_units > max_units
      errors.add(:base, "You can only create up to #{max_units} units.")
    end
  end

  def association_due
    association_dues.where(due_type: "dues").last
  end

  def special_assesments
    association_dues.where(due_type: "special_assesment")
  end

  def primary_bank_account
    bank_accounts.find_by(is_primary: true)
  end

  private
  def test_environment?
    Rails.env.test?
  end

  def create_stripe_account_id
    return if test_environment?
    # Standard accounts are fully managed by Stripe dashboard
    # self.stripe_account_id = Stripe::Account.create({type: 'standard', email: self.email, country: 'US',})['id']
    stripe_account_id = Stripe::Account.create({
      type: 'custom',
      country: 'US',
      email: self.email,
      capabilities: { transfers: { requested: true } },
      business_type: 'individual'
    })['id']
    self.update_column(:stripe_account_id, stripe_account_id)
  end

  def create_user_on_unityfi
    return if test_environment?
    unityfi_service = UnityfiService.new
    unityfi_service.create_location_user(self)
  end
end
