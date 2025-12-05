class User < ApplicationRecord
  acts_as_paranoid
  rolify
	devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :associations, class_name: "Association", foreign_key: "property_manager_id", dependent: :destroy
  has_many :admin_units, class_name: "Unit", foreign_key: :created_by, dependent: :destroy
  scope :property_owners, -> { with_role(:PropertyOwner) }
  belongs_to :custom_association, class_name: "Association", foreign_key: :association_id, optional: true
  has_many :walkthroughs, class_name: "Walkthrough", foreign_key: :created_by, dependent: :destroy
  def full_name
    "#{first_name} #{last_name}".strip
  end

  has_many :community_association_managers, dependent: :destroy

  # has_many :bank_accounts, class_name: "BankAccount", foreign_key: :created_by, dependent: :destroy
  has_many :bank_accounts, as: :bank_accountable, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :payment_methods, dependent: :destroy
  has_many :amenity_reservations, dependent: :destroy
  def is_subscription_active
    subscription = subscriptions.where(status: "active").last
    return subscription.present? && subscription.end_date.present? && subscription.end_date >= Time.current
  end

  def active_subscription
    subscriptions.where(status: "active").order(created_at: :desc).first
  end

  def primary_bank_account
    bank_accounts.find_by(is_primary: true)
  end

  def primary_card
    payment_methods.find_by(is_primary: true)
  end
  # def can_create_more_units?(user)
  #   Unit.joins(:custom_association).where(associations: { property_manager_id: user.id }).count < (user.number_units_subscribe || 0)
  # end
end