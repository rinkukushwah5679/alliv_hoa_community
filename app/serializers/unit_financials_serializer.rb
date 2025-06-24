class UnitFinancialsSerializer < BaseSerializer
  attributes :id, :amount, :frequency, :start_date, :unit_id, :association_id, :created_at, :updated_at
end