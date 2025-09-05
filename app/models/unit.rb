class Unit < ApplicationRecord
  acts_as_paranoid
	has_paper_trail :on => [:update]
  validates :surface_area, presence: true
	belongs_to :custom_association, class_name: "Association", foreign_key: :association_id, optional: true
	has_one :ownership_account, dependent: :destroy
	has_many :unit_financials, dependent: :destroy
	has_many :unit_files, dependent: :destroy
	accepts_nested_attributes_for :ownership_account
	accepts_nested_attributes_for :unit_financials, allow_destroy: true
	accepts_nested_attributes_for :unit_files, allow_destroy: true
	has_one_attached :notice_document
	# before_create :user_unit_limit_not_exceeded
	# before_create :set_unit_number
  after_save :check_surface_area_change
  # before_commit :update_allocation
  after_destroy :recalculate_allocation_after_destroy
 
  # def update_allocation
  #   if destroyed?
  #     # debugger
  #   end
  # end
  def set_unit_number
    last_unit_number = Unit.unscoped.maximum(:unit_number) || 001
    self.unit_number = last_unit_number + 1
  end

	def user_unit_limit_not_exceeded
    return unless custom_association.present? && custom_association&.user.present?

    @user = custom_association.user
    max_units_allowed = @user.number_units_subscribe || 0
    total_units = Unit
      .joins(:custom_association)
      .where(associations: { property_manager_id: custom_association.property_manager_id })
      .count

    if total_units >= max_units_allowed
      errors.add(:base, "You can only create up to #{max_units_allowed} units. unit")
      throw(:abort)
    end
  end

  def full_address
    "#{street}, #{city} #{zip_code}".strip
  end

  private

  def check_surface_area_change
    # if saved_change_to_surface_area? && custom_association.units.present?
    #   units = custom_association.units
    #   total = units.sum(:surface_area).to_f
    #   units.each do |unit|
    #     percentag = (unit.surface_area.to_f / total * 100).round(2)
    #     unit.update_column(:allocation, percentag)
    #   end
    #   puts "Surface area changed from #{surface_area_before_last_save} to #{surface_area}"
    # end

    return unless saved_change_to_surface_area?
    return unless custom_association.present?

    units = custom_association.units
    total = units.sum(:surface_area).to_f

    return if total.zero?

    units.find_each do |unit|
      percentage = (unit.surface_area.to_f / total * 100)
      unit.update_column(:allocation, percentage)
    end

    Rails.logger.info "Surface area changed from #{surface_area_before_last_save} to #{surface_area}"
  end

  def recalculate_allocation_after_destroy
    return unless custom_association.present?

    units = custom_association.units
    total = units.sum(:surface_area).to_f

    return if total.zero?

    units.find_each do |unit|
      percentage = (unit.surface_area.to_f / total * 100)
      unit.update_column(:allocation, percentage)
    end

    Rails.logger.info "Unit deleted. Allocation re-calculated for remaining units."
  end
end
