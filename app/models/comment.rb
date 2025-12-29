class Comment < ApplicationRecord
  default_scope { order(created_at: :desc) }
	has_many_attached :comment_files
	validates :title, presence: true
	belongs_to :commentable, polymorphic: true
	belongs_to :user
end
