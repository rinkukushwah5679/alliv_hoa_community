class Unit < ApplicationRecord
  acts_as_paranoid
	has_paper_trail :on => [:update]
  validates :surface_area, :unit_number, presence: true
  # validates :unit_number, presence: true, format: { with: /\A\d+\z/, message: "only allows numbers" }
  # validates :unit_number, presence: true, numericality: {only_integer: true, greater_than: 0}
  # validate :unit_number_should_not_have_alphabets
	belongs_to :custom_association, class_name: "Association", foreign_key: :association_id, optional: true
	has_one :ownership_account, dependent: :destroy
	has_many :unit_financials, dependent: :destroy
	has_many :unit_files, dependent: :destroy
  has_many :work_orders, dependent: :destroy # I think it's should be
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

  def amount_due(association_due)
    due = association_due
    # return 0 unless due.present?
    return due.amount*surface_area if due.distribution_type ==  "Pro Rata Distribution"
    return due.amount
  end

  def apply_late_fee_for_date?(late_fee_config, due_date)
    return false if late_fee_config.blank? || due_date.blank?

    case late_fee_config.frequency
    when "Next days"
      Date.today > due_date
    when "After 3 days"
      Date.today > (due_date + 3.days)
    when "After 7 days"
      Date.today > (due_date + 7.days)
    when "After 15 days"
      Date.today > (due_date + 15.days)
    else
      false
    end
  end

 def calculate_convenience_fee(amount)
    fee_record = ConvenienceFee.where(
      "transaction_amount_from <= ? AND transaction_amount_to >= ?", amount, amount
    ).first

    return 0 unless fee_record.present?

    (amount * (fee_record.con_variable / 100)).round(2)
  end


  def calculate_due_entries(association_due, ownership_account, late_fee_config, ach_monthly_fee)
    results = []
    return results unless association_due.frequency == "Monthly"

    due_day = association_due.start_date.day
    start_month = association_due.start_date.beginning_of_month
    current_month = Date.today.beginning_of_month

    (start_month..current_month).select { |d| d.day == 1 }.each do |month|
      due_date = Date.new(month.year, month.month, [due_day, Time.days_in_month(month.month, month.year)].min)
      next if due_date >= Date.today
      next if ownership_account.date_of_purchase >= due_date

      payment_month_str = month.strftime("%m-%Y")
      already_paid = Payment.exists?(
        user_id: ownership_account.unit_owner_id, #id of resident 
        unit_id: self.id,
        payment_month: payment_month_str,
        status: ["success", "credit_awaiting", "credit_success", "payment_awaiting", "payment_failed"],
        association_due_id: association_due.id
      )
      next if already_paid

      amount_due = self.amount_due(association_due)
      total_amount = amount_due
      apply_late_fee = late_fee_config.present? && late_fee_config.amount.to_f >= 1 && self.apply_late_fee_for_date?(late_fee_config, due_date)
      total_amount += late_fee_config.amount.to_f if apply_late_fee
      total_dues = total_amount
      convenience_fee_only_due_and_late_fee = calculate_convenience_fee(total_amount)
      total_amount += convenience_fee_only_due_and_late_fee + ach_monthly_fee
      convenience_fee = ach_monthly_fee + convenience_fee_only_due_and_late_fee

      results << {
        unit_id: self.id,
        unit: self.unit_number,
        unit_name: self&.name,
        type: "Monthly Due",
        amount: amount_due,
        late_fee: apply_late_fee ? late_fee_config.amount : 0,
        total_dues: total_dues,
        unityfi_ach_monthly_fee: ach_monthly_fee,
        ach_convenience_fee: convenience_fee,
        total_amount: total_amount,
        due_date: due_date,
        association_due_id: association_due.id
      }
    end
    results
  end

  def calculate_special_assesment_monthly(association_due, ownership_account, late_fee_config)
    results = []
    return results if association_due.start_date.blank? || association_due.end_date.blank?

    due_day = association_due.start_date.day
    current_month = Date.today.beginning_of_month

    (association_due.start_date.beginning_of_month..[association_due.end_date.beginning_of_month, current_month].min)
      .select { |d| d.day == 1 }
      .each do |month|

        due_date = Date.new(month.year, month.month, [due_day, Time.days_in_month(month.month, month.year)].min)
        next if due_date >= Date.today
        next if ownership_account.date_of_purchase >= due_date

        payment_month_str = month.strftime("%m-%Y")
        already_paid = Payment.exists?(
          user_id: ownership_account.unit_owner_id,
          unit_id: self.id,
          payment_month: payment_month_str,
          status: ["success", "credit_awaiting", "credit_success", "payment_awaiting", "payment_failed"],
          association_due_id: association_due.id
        )
        next if already_paid

        amount_due = self.amount_due(association_due)
        total_amount = amount_due
        apply_late_fee = late_fee_config.present? && late_fee_config.amount.to_f >= 0.01 && self.apply_late_fee_for_date?(late_fee_config, due_date)
        total_amount += late_fee_config.amount.to_f if apply_late_fee
        total_dues = total_amount
        convenience_fee = calculate_convenience_fee(total_amount)
        total_amount += convenience_fee
        results << {
          unit_id: self.id,
          unit: self.unit_number,
          unit_name: self&.name,
          type: "Special Assessment (Monthly)",
          amount: amount_due,
          late_fee: apply_late_fee ? late_fee_config.amount : 0,
          total_dues: total_dues,
          unityfi_ach_monthly_fee: 0,
          ach_convenience_fee: convenience_fee,
          total_amount: total_amount,
          due_date: due_date,
          association_due_id: association_due.id
        }
      end

    results
  end

  def calculate_special_assesment_onetime(association_due, ownership_account, late_fee_config)
    results = []
    return results if association_due.start_date.blank?

    due_date = association_due.start_date
    return results if due_date >= Date.today
    return results if ownership_account.date_of_purchase >= due_date

    already_paid = Payment.exists?(
      user_id: ownership_account.unit_owner_id,
      unit_id: self.id,
      payment_month: due_date.strftime("%m-%Y"),
      status: ["success", "credit_awaiting", "credit_success", "payment_awaiting", "payment_failed"],
      association_due_id: association_due.id
    )
    return results if already_paid

    amount_due = self.amount_due(association_due)
    total_amount = amount_due
    apply_late_fee = late_fee_config.present? && late_fee_config.amount.to_f >= 0.01 && self.apply_late_fee_for_date?(late_fee_config, due_date)
    total_amount += late_fee_config.amount.to_f if apply_late_fee
    total_dues = total_amount
    convenience_fee = calculate_convenience_fee(total_amount)
    total_amount += convenience_fee
    results << {
      unit_id: self.id,
      unit: self.unit_number,
      unit_name: self&.name,
      type: "Special Assessment (One-Time)",
      amount: amount_due,
      late_fee: apply_late_fee ? late_fee_config.amount : 0,
      total_dues: total_dues,
      unityfi_ach_monthly_fee: 0,
      ach_convenience_fee: convenience_fee,
      total_amount: total_amount,
      due_date: due_date,
      association_due_id: association_due.id
    }

    results
  end

  def calculate_upcoming_due_entries(association_due, ownership_account, ach_monthly_fee)
    results = []
    return results unless association_due.frequency == "Monthly"

    today = Date.today
    due_day = association_due.start_date.day

    current_due_date = Date.new(today.year, today.month, [due_day, Time.days_in_month(today.month, today.year)].min)
    next_month = today.next_month
    next_due_date = Date.new(next_month.year, next_month.month, [due_day, Time.days_in_month(next_month.month, next_month.year)].min)

    due_date = current_due_date >= today ? current_due_date : next_due_date
    return results if ownership_account.date_of_purchase >= due_date

    payment_month_str = due_date.strftime("%m-%Y")
    already_paid = Payment.exists?(
      user_id: ownership_account.unit_owner_id,
      unit_id: self.id,
      payment_month: payment_month_str,
      status: ["success", "credit_awaiting", "credit_success", "payment_awaiting", "payment_failed"],
      association_due_id: association_due.id
    )
    return results if already_paid

    amount_due = self.amount_due(association_due)
    total_amount = amount_due
    total_dues = total_amount
    convenience_fee_only_mothly_due = calculate_convenience_fee(total_amount)
    total_amount += convenience_fee_only_mothly_due + ach_monthly_fee
    convenience_fee = ach_monthly_fee + convenience_fee_only_mothly_due
    # unit_autopay = UnitAutopay.find_by(unit_id: self.id, user_id: current_user.id)
    # autopay_status = unit_autopay.present? ? unit_autopay.is_active : false
    days_left = (due_date - today).to_i

    results << {
      unit_id: self.id,
      unit: self.unit_number,
      unit_name: self&.name,
      type: "Upcoming monthly due",
      amount: amount_due,
      total_dues: total_dues,
      ach_convenience_fee: convenience_fee,
      unityfi_ach_monthly_fee: ach_monthly_fee,
      total_amount: total_amount,
      due_date: due_date,
      # autopay: autopay_status,
      days_left: days_left,
      association_due_id: association_due.id
    }

    results
  end

  def calculate_upcoming_special_assesment_monthly(association_due, ownership_account)
    results = []
    return results if association_due.start_date.blank? || association_due.end_date.blank?

    today = Date.today
    due_day = association_due.start_date.day
    current_month = today.beginning_of_month

    (association_due.start_date.beginning_of_month..[association_due.end_date.beginning_of_month, current_month + 2.months].min)
      .select { |d| d.day == 1 }
      .each do |month|
        due_date = Date.new(month.year, month.month, [due_day, Time.days_in_month(month.month, month.year)].min)
        next if due_date < today
        next if ownership_account.date_of_purchase >= due_date

        payment_month_str = due_date.strftime("%m-%Y")
        already_paid = Payment.exists?(
          user_id: ownership_account.unit_owner_id,
          unit_id: self.id,
          payment_month: payment_month_str,
          status: ["success", "credit_awaiting", "credit_success", "payment_awaiting", "payment_failed"],
          association_due_id: association_due.id
        )
        next if already_paid

        amount_due = self.amount_due(association_due)
        total_amount = amount_due
        total_dues = total_amount
        convenience_fee = calculate_convenience_fee(total_amount)
        total_amount += convenience_fee
        days_left = (due_date - today).to_i

        results << {
          unit_id: self.id,
          unit: self.unit_number,
          unit_name: self&.name,
          type: "Upcoming Special Assessment (Monthly)",
          amount: amount_due,
          total_dues: total_dues,
          unityfi_ach_monthly_fee: 0,
          ach_convenience_fee: convenience_fee,
          total_amount: total_amount,
          due_date: due_date,
          autopay: false,
          days_left: days_left,
          association_due_id: association_due.id
        }
      end

    results
  end

  def calculate_upcoming_special_assesment_onetime(association_due, ownership_account)
    results = []
    return results if association_due.start_date.blank?

    due_date = association_due.start_date
    today = Date.today

    return results if due_date < today
    return results if ownership_account.date_of_purchase >= due_date

    already_paid = Payment.exists?(
      user_id: ownership_account.unit_owner_id,
      unit_id: self.id,
      payment_month: due_date.strftime("%m-%Y"),
      status: ["success", "credit_awaiting", "credit_success", "payment_awaiting", "payment_failed"],
      association_due_id: association_due.id
    )
    return results if already_paid

    amount_due = self.amount_due(association_due)
    total_amount = amount_due
    total_dues = total_amount
    convenience_fee = calculate_convenience_fee(total_amount)
    total_amount += convenience_fee
    days_left = (due_date - today).to_i

    results << {
      unit_id: self.id,
      unit: self.unit_number,
      unit_name: self&.name,
      type: "Upcoming Special Assessment (One-Time)",
      amount: amount_due,
      total_dues: total_dues,
      unityfi_ach_monthly_fee: 0,
      ach_convenience_fee: convenience_fee,
      total_amount: total_amount,
      due_date: due_date,
      autopay: false,
      days_left: days_left,
      association_due_id: association_due.id
    }

    results
  end

  private

  def unit_number_should_not_have_alphabets
    raw_value = unit_number_before_type_cast
    return if raw_value.blank?

    unless raw_value.to_s.match?(/\A\d+\z/)
      errors.add(:base, "Alphabet not allow into Unit number")
    end
  end

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
