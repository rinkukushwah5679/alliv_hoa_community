class Transaction < ApplicationRecord
	has_paper_trail :on => [:update]
	acts_as_paranoid
	default_scope { order(created_at: :asc) }
	validates :transaction_date, presence: true
	has_many :payments, dependent: :destroy
	accepts_nested_attributes_for :payments, allow_destroy: true
	has_many_attached :transaction_files
	has_many :transaction_lines, dependent: :destroy
	accepts_nested_attributes_for :transaction_lines, allow_destroy: true
	enum :payment_terms, {"Due on Receipt" => "Due on Receipt", "Net-15" => "Net-15", "Net-30" => "Net-30", "Net-45" => "Net-45"}
	belongs_to :user, optional: true
	belongs_to :unit, optional: true
	belongs_to :association_due, optional: true
	belongs_to :work_order, optional: true
	belongs_to :custom_association, class_name: "Association", foreign_key: :association_id
	belongs_to :creator, class_name: "User", foreign_key: :created_by, optional: true
	has_many :comments, as: :commentable, dependent: :destroy
	has_many :notifications, as: :notifiable, dependent: :destroy
end
