module V1
	class VotingRulesController < ApplicationController
		before_action :set_voting_rules, only: [:show, :update, :destroy]

		def index
			begin
				return if set_association_from_params! == :rendered
				voting_rules = fetch_voting_rules
				page = params[:page] || 1
				per_page = params[:per_page] || 10
				voting_rules = voting_rules.select("voting_rules.*, a.id AS a_id, a.name AS a_name").joins("INNER JOIN associations as a on a.id = voting_rules.association_id").order(created_at: :desc).paginate(page: page, per_page: per_page)
				total_pages = voting_rules.total_pages
				return render json: {status: 200, success: true, data: VotingRulesSerializer.new(voting_rules).serializable_hash[:data], pagination_data: { total_pages: total_pages, total_records: voting_rules.count}, message: "List"}
			rescue StandardError => e
				render json: {status: 500, success: false, data: nil, message: e.message}
			end
		end

		def show
			render json: {status: 200, success: true, data: VotingRulesSerializer.new(@voting_rule).serializable_hash[:data], message: "Details"}
		end

		def update
			begin
				if @voting_rule.update(voting_rule_params)
					render json: {status: 200, success: true, data: VotingRulesSerializer.new(@voting_rule).serializable_hash[:data], message: "Updated successfully."}
				else
					render json: {status: 422, success: false, data: nil, message: @voting_rule.errors.full_messages.join(", ")}

				end
			rescue StandardError => e
				render json: {status: 500, success: false, data: nil, message: e.message}
			end
		end

		def destroy
			@voting_rule.destroy
			render json: {status: 200, success: true, data: nil, message: "Successfully destroyed."}
		end

		private

		def voting_rule_params
			params.require(:voting_rule).permit(:status)
		end

		def set_voting_rules
			@voting_rule = VotingRule.select("voting_rules.*, a.id AS a_id, a.name AS a_name").joins("INNER JOIN associations as a on a.id = voting_rules.association_id").find_by(id: params[:id])
			return render json: {status: 404, success: false, data: nil, message: "Voting rule not found"} unless @voting_rule.present?
		end

		# Reusable association setter
		def set_association_from_params!
			return unless params[:association_id].present?
			@association = Association.find_by(id: params[:association_id])

			unless @association
				render json: {status: 404, success: false, data: nil, message: "Association not found"}
				return :rendered
			end
		end

		def fetch_voting_rules
			voting_rules = if @association.present?
				@association.voting_rules
			else
				associations = Association
					.left_joins(units: :ownership_account)
				  .left_joins(:community_association_managers)
				  .yield_self { |query|
				    case current_user.current_role
				    when "Resident"
				      query = query.where("ownership_accounts.unit_owner_id = ?", current_user.id)
				    when "AssociationManager"
				      query = query.where("community_association_managers.user_id = ?", current_user.id)
				    else# "BoardMember", "SystemAdmin"
				      query = query.where("associations.property_manager_id = ?", current_user.id)
				    end
				    query
				  }
				  .distinct
				association_ids = associations.map(&:id)
				if current_user.current_role == "Resident"
					VotingRule.where(association_id: association_ids, participant_category: "All Members")
				else
					VotingRule.where(association_id: association_ids)
				end
			end
			voting_rules = voting_rules.joins("INNER JOIN associations ON associations.id = voting_rules.association_id")

			if params[:search].present?
				search_term = "%#{params[:search]}%"

				# 1st try: filter by association name
				filtered = voting_rules.where("associations.name ILIKE ?", search_term)

				# if no results → fallback to ratification_type
				voting_rules = if filtered.exists?
					filtered
				else
					voting_rules.where("voting_rules.ratification_type ILIKE ?", search_term)
				end
			end

			voting_rules
		end
	end
end