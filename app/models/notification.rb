class Notification < ApplicationRecord
  has_paper_trail :on => [:update]
  belongs_to :user
  belongs_to :notifiable, polymorphic: true
  default_scope { order(created_at: :desc) }
end
