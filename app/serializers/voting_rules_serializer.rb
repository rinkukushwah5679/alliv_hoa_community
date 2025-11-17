class VotingRulesSerializer < BaseSerializer
  attributes :id, :auto_generate_id, :created_date, :ratification_type, :status

  attribute :created_date do |object|
    object.created_at.strftime("%m/%d/%Y")
  end
end
