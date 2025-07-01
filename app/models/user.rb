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
  has_many :bank_accounts, dependent: :destroy

  # def can_create_more_units?(user)
  #   Unit.joins(:custom_association).where(associations: { property_manager_id: user.id }).count < (user.number_units_subscribe || 0)
  # end
end