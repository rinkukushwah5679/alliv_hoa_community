class Address < ApplicationRecord
  enum address_type: %w(Primary Alternate)
  belongs_to :addressable, polymorphic: true
  # validates :address_line1, :country, presence: true
  belongs_to :creator, class_name: "User", foreign_key: :created_by, primary_key: :id
  belongs_to :updater, class_name: "User", foreign_key: :updated_by, primary_key: :id
  after_save :ensure_only_one_primary

  private
  def ensure_only_one_primary
    if Primary?
      addressable.addresses.where.not(id: id).update_all(address_type: :Alternate)
    end
  end
end
