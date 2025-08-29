class PaymentMethod < ApplicationRecord
	belongs_to :user
	default_scope { order(created_at: :asc) }
  # validates :stripe_pm_id, presence: true
end