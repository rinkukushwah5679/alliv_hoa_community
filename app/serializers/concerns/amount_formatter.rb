module AmountFormatter
  def format_amount(amount)
    return "0.00" if amount.blank?

    # Ensure numeric
    amount = amount.to_f

    whole, decimal = format("%.2f", amount).split(".")

    whole_with_commas = whole.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse

    "#{whole_with_commas}.#{decimal}"
  end
end
