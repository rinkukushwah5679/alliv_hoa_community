class VotingRulesSerializer < BaseSerializer
  attributes :id, :auto_generate_id, :created_date, :association_id, :association_name, :ruleset_category, :ratification_type, :status, :updated_at

  attribute :created_date do |object|
    object.created_at.strftime("%m/%d/%Y")
  end

  attribute :association_name do |object|
    object.a_name rescue nil
  end

  attribute :ruleset_category do |object|
    object.participant_category rescue nil
  end
end
