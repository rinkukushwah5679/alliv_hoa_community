class User < ApplicationRecord
  rolify
	devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :associations, class_name: "Association", foreign_key: "property_manager_id"
  scope :property_owners, -> { with_role(:PropertyOwner) }
  def full_name
    "#{first_name} #{last_name}".strip
  end
end