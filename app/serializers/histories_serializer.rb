class HistoriesSerializer < BaseSerializer
  attributes :id, :date, :event_type

  attribute :date do |object|
    object.created_at
  end

  attribute :event_type do |object|
    object.object_changes
  end
end
