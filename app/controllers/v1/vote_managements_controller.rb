module V1
	class VoteManagementsController < ApplicationController
		before_action :set_vote_management, only: [:show, :update, :destroy, :update_status]

		def index
			begin
				return if set_association_from_params! == :rendered
				vote_managements = fetch_vote_managements
				page = params[:page] || 1
				per_page_value = Setting.per_page_records
				per_page = params[:per_page] || per_page_value
				vote_managements = vote_managements.order(created_at: :desc).paginate(page: page, per_page: per_page)
				total_pages = vote_managements.total_pages
				return render json: {status: 200, success: true, data: VoteManagementSerializer.new(vote_managements).serializable_hash[:data], pagination_data: { total_pages: total_pages, total_records: vote_managements.count}, message: "List"}
			rescue StandardError => e
				Rails.logger.info "==========Vote Management listing error #{e.message}"
				render json: {status: 500, success: false, data: nil, message: e.message}
			end
		end

		def show
			render json: {status: 200, success: true, data: VoteManagementDetailsSerializer.new(@vote_management).serializable_hash[:data], message: "Details"}
		end

		def create
			begin
				vote_management = VoteManagement.new(vote_management_params)
				if vote_management.save
					return render json: {status: 201, success: true, data: VoteManagementCreateSerializer.new(vote_management).serializable_hash[:data], message: 'Vote management created successfully.'}
				else
					render json: {status: 422, success: false, data: nil, message: vote_management.errors.full_messages.join(", ")}
				end
			rescue StandardError => e
				Rails.logger.info "==========Vote management create error #{e.message}"
				render json: { status: 500, success: false, data: nil, message: e.message }
			end
			
		end

		def update
			begin
				new_files = params[:vote_management][:vote_management_attachments] rescue nil
				if @vote_management.update(update_vote_management_params)
					if new_files.present?
						new_files.each do |file|
							@vote_management.vote_management_attachments.attach(file)
						end
					end
					render json: {status: 200, success: true, data: VoteManagementDetailsSerializer.new(@vote_management).serializable_hash[:data], message: "Updated successfully."}
				else
					render json: {status: 422, success: false, data: nil, message: @vote_management.errors.full_messages.join(", ")}

				end
			rescue StandardError => e
				Rails.logger.info "==========Vote management update error #{e.message}"
				render json: {status: 500, success: false, data: nil, message: e.message}
			end
		end

		def destroy
			@vote_management.destroy
			render json: {status: 200, success: true, data: nil, message: "Successfully destroyed."}
		end
		# Only for Resident or Board Member
		def update_status
			begin
				return render json: {status: 422, success: false, data: nil, message: "Voting has closed"} if @vote_management.approval_due_date.present? && @vote_management.approval_due_date < Date.today
				vote_approval = VoteApproval.find_or_initialize_by(user_id: current_user.id, vote_management_id: @vote_management.id)

				if vote_approval.update(vote_approval_params)
					return render json: {status: 200, success: true, data: VoteManagementDetailsSerializer.new(@vote_management).serializable_hash[:data], message: "Status updates to #{vote_approval_params[:status]}"}
				else
					return render json: {status: 422, success: false, data: nil, message: vote_approval.errors.full_messages.join(", ")}
				end
			rescue StandardError => e
				Rails.logger.info "==========Update status for approval error #{e.message}"
				render json: {status: 500, success: false, data: nil, message: e.message}
			end
		end

		private

		def vote_management_params
			params.require(:vote_management).permit(:created_date, :association_id, :meeting_type, :voting_rule_id, :participant_category, :ratification_type, :title, :description, :approval_due_date, vote_management_attachments: [])
		end

		def update_vote_management_params
			params.require(:vote_management).permit(:created_date, :association_id, :meeting_type, :voting_rule_id, :participant_category, :ratification_type, :title, :description, :approval_due_date)
		end

		def vote_approval_params
			params.require(:vote_approval).permit(:status, :association_id)
		end

		def set_vote_management
			@vote_management = VoteManagement
				.select("vote_managements.*, a.id AS a_id, a.name AS a_name, c.id AS c_id, c.profile_pic_url AS c_profile_pic_url, c.first_name AS c_first_name, c.last_name AS c_last_name")
				.joins("INNER JOIN associations as a on a.id = vote_managements.association_id")
				.joins("LEFT JOIN users as c ON c.id = vote_managements.created_by")
				.find_by(id: params[:id])
			return render json: {status: 404, success: false, data: nil, message: "Vote management not found"} unless @vote_management.present?
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

		def fetch_vote_managements
			vote_managements = if @association.present?
				@association.vote_managements
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
					VoteManagement.where(association_id: association_ids, participant_category: "All Members")
				else
					VoteManagement.where(association_id: association_ids)
				end
			end

			if params[:vote_approvals].present? && params[:vote_approvals].to_s == "true"
				vote_managements = vote_managements.where(status: "Open")
			else
				vote_managements = vote_managements
			end
			vote_managements = vote_managements
				.select("vote_managements.*, a.id AS a_id, a.name AS a_name, c.id AS c_id, c.profile_pic_url AS c_profile_pic_url, c.first_name AS c_first_name, c.last_name AS c_last_name")
				.joins("INNER JOIN associations as a on a.id = vote_managements.association_id")
				.joins("INNER JOIN associations ON associations.id = vote_managements.association_id")
				.joins("LEFT JOIN users as c ON c.id = vote_managements.created_by")

			if params[:search].present?
				search_term = "%#{params[:search]}%"

				# 1st try: filter by association name
				filtered = vote_managements.where("associations.name ILIKE ?", search_term)

				# if no results → fallback to ratification_type
				vote_managements = if filtered.exists?
					filtered
				else
					vote_managements.where("vote_managements.ratification_type ILIKE :search OR vote_managements.title ILIKE :search",search: search_term)

				end
			end

			vote_managements
		end
	end
end