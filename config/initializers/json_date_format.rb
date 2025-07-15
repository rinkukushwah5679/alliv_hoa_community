# For datetime values like created_at, updated_at, etc.
class ActiveSupport::TimeWithZone
  def as_json(_options = nil)
    strftime("%m/%d/%Y %I:%M %p")
  end
end

# For Date values
class Date
  def as_json(_options = nil)
    strftime("%m/%d/%Y")
  end
end

# For DateTime values (optional)
class DateTime
  def as_json(_options = nil)
    strftime("%m/%d/%Y %I:%M %p")
  end
end
