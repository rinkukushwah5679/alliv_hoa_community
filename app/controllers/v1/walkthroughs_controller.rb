module V1
	class WalkthroughsController < ApplicationController
		# before_action :set_association, except: [:index]
		before_action :set_walkthrough, only: [:show, :update, :destroy]
		# The manager is not mentioned in the document.
		def index
			begin
				return if set_association_from_params! == :rendered
				walkthroughs = fetch_walkthroughs
				# if params[:association_id].present?
				# 	association = Association.find_by(id: params[:association_id])
				# 	return render json: {status: 404, success: false, data: nil, message: "Associdation not found"} unless association.present?
				# 	walkthroughs = association.walkthroughs.order("created_at DESC")
				# else
				# 	walkthroughs = current_user.walkthroughs.order("created_at DESC")
				# end

				# Data filterd with date range
				# if params[:start_date].present? && params[:end_date].present?
				# 	walkthroughs = walkthroughs.where(created_at: params[:start_date].to_date.beginning_of_day..params[:end_date].to_date.end_of_day)
				# end
				per_page_value = Setting.per_page_records
				walkthroughs = walkthroughs.paginate(page: (params[:page] || 1), per_page: (params[:per_page] || per_page_value))

				if params[:export] == "true"
					require 'csv'
					# Ensure folder exists
					export_dir = Rails.root.join("tmp", "exports")
					FileUtils.mkdir_p(export_dir)

					filename = "walkthroughs_time_#{Time.now.to_i}.csv"
					filepath = export_dir.join(filename)

					CSV.open(filepath, "w", write_headers: true, headers: ["Association Name", "Property Manager Name", "Date Submitted", "Submitted by", "Health Score"]) do |csv|
						walkthroughs.each do |walk|
							csv << [
								walk&.custom_association&.name,
								walk&.user&.full_name,
								walk&.created_at.to_date,
								walk&.creator&.full_name,
								walk&.health_score
							]
						end
					end
					# Generate file download URL (adjust to match your domain)
					download_url = "#{ENV['HOA_COMMUNITY_SERVER_URL']}/v1/download_file?filename=#{filename}"
					return render json: {status: 200, success: true, data: {url: download_url}, message: "Export successfully" }, status: :ok
				else
					if walkthroughs.present?
						# health_score = ((walkthroughs.map(&:health_score).sum.to_f)/walkthroughs.count).round(2)
						health_score = (walkthroughs.sum(:health_score).to_f / walkthroughs.count).round(2)
					else
						health_score = 0.0
					end
					total_pages = walkthroughs.present? ? walkthroughs.total_pages : 0
					render json: {status: 200, success: true, data: WalkthroughsSerializer.new(walkthroughs).serializable_hash[:data], health_score: health_score, pagination_data: {total_pages: total_pages, total_records: walkthroughs.count}, message: "Walkthroughs list"}, :status => :ok
				end
			rescue StandardError => e
				render json: {status: 500, success: false, data: nil, message: e.message }, status: :internal_server_error
			end
		end

		def show
			render json: {status: 200, success: true, data: WalkthroughDetailsSerializer.new(@walkthrough).serializable_hash[:data], message: "Walkthrough details"}, :status => :ok
		end

		def create
			begin
				return render json: {status: 422, success: false, data: nil, message: "Please select association"}, :status => :unprocessable_entity if params[:walkthrough][:association_id].blank?
				@walkthrough = Walkthrough.new(walkthrough_params)
				if @walkthrough.save
					render json: {status: 201, success: true, data: WalkthroughDetailsSerializer.new(@walkthrough).serializable_hash[:data], message: "Walkthrough created successfully"}, :status => :created
				else
					render json: {status: 422, success: false, data: nil, message: @walkthrough.errors.full_messages.join(", ")}, :status => :unprocessable_entity
				end
			rescue StandardError => e
				render json: {status: 500, success: false, data: nil, message: e.message}, status: :internal_server_error
			end
		end

		def update
			begin
				if @walkthrough.update(walkthrough_params)
					render json: {status: 200, success: true, data: WalkthroughDetailsSerializer.new(@walkthrough).serializable_hash[:data], message: "Walkthrough updated successfully"}, :status => :ok
				else
					render json: {status: 422, success: false, data: nil, message: @walkthrough.errors.full_messages.join(", ")}, :status => :unprocessable_entity
				end
			rescue StandardError => e
				render json: {status: 500, success: false, data: nil, message: e.message}, status: :internal_server_error
			end
		end

		def destroy
			@walkthrough.destroy
			render json: {status: 200, success: true, data: nil, message: "Walkthrough successfully destroyed."}, status: :ok
		end


		private
		def walkthrough_params
			params.require(:walkthrough).permit(
			  :association_id,
			  :user_id,
			  :facade,
				:balcony,
				:window_door_screens,
				:balcony_door_frame,
				:front_doors,
				:landscaping,
				:sliding,
				:exterior_stairwells,
				:dryer_vent_covers,
				:rodents_critters,
				:gutters,
				:roof,
				:lights,
				:spigots,
				:sprinkler_systems,
				:mailboxes,
				:trash_bins,
				:leaks,
				:unit_numbers,
				:gate_doors,
				:decoration,
				:internet_phone_lines,
				:vandalization,
				:vehicles,
				:facade_enhancements,
				:lendscaping_enhancements,
				:other_improvements,
				:roof_improvements,
				:miscellaneous,
				:health_score,
				:scores => {},
			  facade_attachments: [],
				balcony_attachments: [],
				window_door_screens_attachments: [],
				balcony_door_frame_attachments: [],
				front_doors_attachments: [],
				landscaping_attachments: [],
				sliding_attachments: [],
				exterior_stairwells_attachments: [],
				dryer_vent_covers_attachments: [],
				rodents_critters_attachments: [],
				gutters_attachments: [],
				roof_attachments: [],
				lights_attachments: [],
				spigots_attachments: [],
				sprinkler_systems_attachments: [],
				mailboxes_attachments: [],
				trash_bins_attachments: [],
				leaks_attachments: [],
				unit_numbers_attachments: [],
				gate_doors_attachments: [],
				decoration_attachments: [],
				internet_phone_lines_attachments: [],
				vandalization_attachments: [],
				vehicles_attachments: [],
				facade_enhancements_attachments: [],
				lendscaping_enhancements_attachments: [],
				other_improvements_attachments: [],
				roof_improvements_attachments: [],
				miscellaneous_attachments: []
			)
		end

		def set_association
			# @association = Association.find_by_id(params[:association_id]) if params[:association_id]
			# return render json: {status: 404, success: false, data: nil, message: "Assdociation not found"}, :status => :not_found unless @association.present?
		end

		def set_walkthrough
			@walkthrough = Walkthrough.find_by_id(params[:id]) if params[:id]
			return render json: {status: 404, success: false, data: nil, message: "Walkthrough not found"}, :status => :not_found unless @walkthrough.present?
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

		def fetch_walkthroughs
			walkthroughs = if @association.present?
				@association.walkthroughs
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
				Walkthrough.where(association_id: association_ids)
			end

			# Data filterd with date range
			if params[:start_date].present? && params[:end_date].present?
				walkthroughs = walkthroughs.where(created_at: params[:start_date].to_date.beginning_of_day..params[:end_date].to_date.end_of_day)
			end
			walkthroughs = walkthroughs
				.select("walkthroughs.*, a.id AS a_id, a.name AS a_name, c.id AS c_id, c.profile_pic_url AS c_profile_pic_url, c.first_name AS c_first_name, c.last_name AS c_last_name")
				.joins("INNER JOIN associations as a on a.id = walkthroughs.association_id")
				.joins("INNER JOIN associations ON associations.id = walkthroughs.association_id")
				.joins("LEFT JOIN users as c ON c.id = walkthroughs.created_by")

			if params[:search].present?
				search_term = "%#{params[:search]}%"

				# 1st try: filter by association name
				filtered = walkthroughs.where("associations.name ILIKE ?", search_term)

				walkthroughs = filtered
			end

			walkthroughs
		end
	end
end