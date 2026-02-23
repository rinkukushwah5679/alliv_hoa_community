module V1
	class AmenitiesController < ApplicationController
		before_action :set_amenity, only: [:show, :update, :destroy]

		def index
			begin
				return if set_association_from_params! == :rendered
				amenities = fetch_amenities
				page = params[:page] || 1
				per_page_value = Setting.per_page_records
				per_page = params[:per_page] || per_page_value
				amenities = amenities.order(created_at: :desc).paginate(page: page, per_page: per_page)
				total_pages = amenities.total_pages
				return render json: {status: 200, success: true, data: AmenitiesSerializer.new(amenities).serializable_hash[:data], total_amenities: amenities.count, pagination_data: { total_pages: total_pages, total_records: amenities.count}, message: "Amenity list"}
			rescue StandardError => e
				Rails.logger.info "==========Amenity listing error #{e.message}"
				render json: {status: 500, success: false, data: nil, message: e.message}
			end
		end

		def show
			render json: {status: 200, success: true, data: AmenitiesDetailsSerializer.new(@amenity).serializable_hash[:data], message: "Details"}
		end

		def create
			begin
				@amenity = Amenity.new(amenities_params)
				if @amenity.save
					notification_for_amenity_booking_when_create(@amenity)
					render json: {status: 200, success: true, data: AmenitiesSerializer.new(@amenity).serializable_hash[:data], message: "Updated successfully."}
				else
					render json: {status: 422, success: false, data: nil, message: @amenity.errors.full_messages.join(", ")}

				end
			rescue StandardError => e
				Rails.logger.info "==========Amenity create error #{e.message}"
				render json: {status: 500, success: false, data: nil, message: e.message}
			end
		end

		def update
			begin
				new_files = params[:amenity][:amenity_attachments] rescue nil
				if @amenity.update(update_amenities_params)
					if new_files.present?
						new_files.each do |file|
							@amenity.amenity_attachments.attach(file)
						end
					end
					render json: {status: 200, success: true, data: AmenitiesDetailsSerializer.new(@amenity).serializable_hash[:data], message: "Updated successfully."}
				else
					render json: {status: 422, success: false, data: nil, message: @amenity.errors.full_messages.join(", ")}

				end
			rescue StandardError => e
				Rails.logger.info "==========Amenity update error #{e.message}"
				render json: {status: 500, success: false, data: nil, message: e.message}
			end
		end

		def destroy
			@amenity.destroy
			render json: {status: 200, success: true, data: nil, message: "Amenity successfully destroyed."}
		end

		private

		def notification_for_amenity_booking_when_create(amenity)
			begin
		    association_id = amenity.association_id

		    # -------------------------------
		    resident_ids = []
		    # manager_ids = []
		    if amenity.participants == "All Members"
		    	# Residents
			    resident_ids = OwnershipAccount.where(association_id: association_id).pluck(:unit_owner_id)
			  end

			  # recipients =
				#   case amenity.participants
				#   when "All Members"
				#     association.unit_owners + association.board_members
				#   when "Board Only"
				#     association.board_members
				#   else
				#     []
				#   end

		    # -------------------------------
		    # Unique Users
		    user_ids = (resident_ids).uniq
		    association = amenity.custom_association

		    User
		      .where(id: user_ids)
		      .includes(:user_setting)
		      .find_each do |user|

		        setting = user.user_setting
		        next if setting.present? && !setting.is_notification# && !setting.announcements_notifications

		        AmenityMailer.notification_for_amenity_booking(user, amenity, association).deliver_later
		      end
	      board_members = association.board_members

				board_members.each do |board_member|
					setting = board_member.user_setting
	        next if setting.present? && !setting.is_notification
					AmenityMailer.board_members_notification_for_amenity_booking(board_member, amenity, association).deliver_later
				end
		  rescue StandardError => e
		    Rails.logger.error "*******Amenity Notification Job Error: #{e.message}"
		  end
		end

		def amenities_params
			params.require(:amenity).permit(:association_id, :amenity_name, :description, :serial_number_sku, :location, :participants, :quantity, amenity_attachments: [])
		end

		def update_amenities_params
			params.require(:amenity).permit(:association_id, :amenity_name, :description, :serial_number_sku, :location, :participants, :quantity)
		end

		def set_amenity
			@amenity = Amenity.select("amenities.*, a.id AS a_id, a.name AS a_name").joins("INNER JOIN associations as a on a.id = amenities.association_id").find_by(id: params[:id])
			return render json: {status: 404, success: false, data: nil, message: "Amenity not found"} unless @amenity.present?
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

		def fetch_amenities
			amenities = if @association.present?
				@association.amenities
			else
				associations = Association
				  .left_joins(units: :ownership_account)
				  .left_joins(:community_association_managers)
				  .yield_self { |query|
				    # case current_user.current_role
				    case current_user.res_or_sa_of_bm
				    # when "Resident"
				    when "Resident", "BoardMember+Resident"
				      query = query.where("ownership_accounts.unit_owner_id = ?", current_user.id)
				    when "AssociationManager"
				      query = query.where("community_association_managers.user_id = ?", current_user.id)
				    # when "BoardMember", "SystemAdmin"
				    when "SystemAdmin", "BoardMember+SystemAdmin"
				      query = query.where("associations.property_manager_id = ?", current_user.id)
				    else
				      # If there is any other role, then by default check all the roles.
				      query = query.where(
				        "ownership_accounts.unit_owner_id = :user_id OR community_association_managers.user_id = :user_id OR associations.property_manager_id = :user_id",
				        user_id: current_user.id
				      )
				    end
				    query
				  }
				  .distinct
				# associations = current_user.associations
				association_ids = associations.map(&:id)
				# if current_user.current_role == "Resident"
					# Amenity.where(association_id: associations.map(&:id), participants: "All Members")
				# else
				Amenity.where(association_id: associations.map(&:id))
				# end
			end
			if current_user.current_role == "Resident"
				amenities = amenities.where(participants: "All Members")
			end
			amenities = amenities.joins("INNER JOIN associations ON associations.id = amenities.association_id")
			amenities = amenities.where(participants: params[:participants]) if params[:participants].present?
			if params[:search].present?
				search_term = "%#{params[:search].strip}%"

				# 1st try: filter by association name
				filtered = amenities.where("associations.name ILIKE ?", search_term)

				# if no results → fallback to approval_type
				amenities = if filtered.exists?
					filtered
				else
					amenities.where("amenities.amenity_name ILIKE :search OR serial_number_sku ILIKE :search",search: search_term)
				end
			end
			amenities
		end
	end
end