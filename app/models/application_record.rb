class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
  before_save :set_created_by_updated_by_user
  private
  def current_user
    RequestStore.store[:current_user]
  end

  def set_created_by_updated_by_user
    return if Rails.env.test?
    return unless current_user
    self.updated_by = current_user.id if self.has_attribute?(:updated_by)
    self.created_by = current_user.id if new_record? && self.has_attribute?(:created_by)
  end
end
