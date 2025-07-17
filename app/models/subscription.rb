class Subscription < ApplicationRecord
	acts_as_paranoid
	default_scope { order(created_at: :desc) }
	enum :billing_type, { monthly: "monthly", annual: "annual" }

	#current subscription: latest active
	validates :units, numericality: { only_integer: true, greater_than: 0 }

	enum :status, { created: "created", active: "active", upgraded: "upgraded", failed: "failed", incomplete: "incomplete", incomplete_expired: "incomplete_expired", past_due: "past_due", unpaid: "unpaid", payment_failed: "payment_failed", canceled: "canceled", expired: "expired", cancellation_requested: "cancellation_requested", schedule_expiring: "schedule_expiring" }
	validates :billing_type, presence: true
	validates :price_per_unit, :units, :amount, presence: true
	belongs_to :user
	belongs_to :unit_plan
	# has_one :billing_detail, dependent: :destroy
	has_many :billing_details, dependent: :destroy
	accepts_nested_attributes_for :billing_details
end