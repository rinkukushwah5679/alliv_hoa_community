class BaseSerializer
  include FastJsonapi::ObjectSerializer
  extend AmountFormatter
end