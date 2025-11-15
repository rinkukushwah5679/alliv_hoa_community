module V1
	class AmenityReservationsController < ApplicationController
		before_action :set_amenity_reservation, only: [:show, :update, :destroy]

		def index
			begin
				return if set_association_from_params! == :rendered
				amenity_reservations = fetch_amenity_reservations
				page = params[:page] || 1
				per_page = params[:per_page] || 10
				amenity_reservations = amenity_reservations.order(created_at: :desc).paginate(page: page, per_page: per_page)
				total_pages = amenity_reservations.total_pages
				return render json: {status: 200, success: true, data: AmenityReservationsSerializer.new(amenity_reservations).serializable_hash[:data], total_amenity_reservations: amenity_reservations.count, pagination_data: { total_pages: total_pages, total_records: amenity_reservations.count}, message: "Amenity reservation list"}
			rescue StandardError => e
				Rails.logger.info "==========Amenity Reservation listing error #{e.message}"
				render json: {status: 500, success: false, data: nil, message: e.message}
			end
		end

		def show
			render json: {status: 200, success: true, data: AmenityReservationDetailsSerializer.new(@amenity_reservation).serializable_hash[:data], message: "Details"}
		end

		def create
			begin
				@amenity_reservation = current_user.amenity_reservations.new(amenities_params)
				if @amenity_reservation.save
					render json: {status: 200, success: true, data: AmenityReservationCreateSerializer.new(@amenity_reservation).serializable_hash[:data], message: "Updated successfully."}
				else
					render json: {status: 422, success: false, data: nil, message: @amenity_reservation.errors.full_messages.join(", ")}

				end
			rescue StandardError => e
				Rails.logger.info "==========Amenity reservation create error #{e.message}"
				render json: {status: 500, success: false, data: nil, message: e.message}
			end
		end

		def update
			begin
				if @amenity_reservation.update(update_amenities_params)
					render json: {status: 200, success: true, data: AmenityReservationDetailsSerializer.new(@amenity_reservation).serializable_hash[:data], message: "Updated successfully."}
				else
					render json: {status: 422, success: false, data: nil, message: @amenity_reservation.errors.full_messages.join(", ")}

				end
			rescue StandardError => e
				Rails.logger.info "==========Amenity reservation update error #{e.message}"
				render json: {status: 500, success: false, data: nil, message: e.message}
			end
		end

		def destroy
			@amenity_reservation.destroy
			render json: {status: 200, success: true, data: nil, message: "Reservation successfully destroyed."}
		end

		private

		def amenities_params
			params.require(:amenity_reservation).permit(:association_id, :amenity_id, :description, :serial_number_sku, :location, :reservation_date, :start_time, :end_time)
		end

		def update_amenities_params
			params.require(:amenity_reservation).permit(:reservation_date, :start_time, :end_time)
		end

		def set_amenity_reservation
			@amenity_reservation = current_user.amenity_reservations.select("amenity_reservations.*, a.id AS a_id, a.name AS a_name, am.id AS am_id, am.amenity_name AS am_amenity_name").joins("INNER JOIN associations as a on a.id = amenity_reservations.association_id").joins("INNER JOIN amenities as am on am.id = amenity_reservations.amenity_id").includes(amenity: [ amenity_attachments_attachments: :blob ]).find_by(id: params[:id])
			return render json: {status: 404, success: false, data: nil, message: "Amenity reservation not found"} unless @amenity_reservation.present?
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

		def fetch_amenity_reservations
			amenity_reservations = if @association.present?
				AmenityReservation.where(user_id: current_user.id, association_id: @association.id)
			else
				associations = Association
				  .left_joins(units: :ownership_account)
				  .yield_self { |query|
				    case current_user.current_role
				    when "Resident"
				      query = query.where("ownership_accounts.unit_owner_id = ?", current_user.id)
				    else
				    	# For "BoardMember"
				      query = query.where("associations.property_manager_id = ?", current_user.id)
				    end
				    query
				  }
				  .distinct
				association_ids = associations.map(&:id)
		    AmenityReservation.where(association_id: associations.map(&:id), user_id: current_user.id)
		    # AmenityReservation.all
			end
			# Always join associations
		  amenity_reservations = amenity_reservations
		  	.select("amenity_reservations.*, a.id AS a_id, a.name AS a_name, am.id AS am_id, am.amenity_name AS am_amenity_name")
		  	.joins("INNER JOIN associations as a on a.id = amenity_reservations.association_id")
		  	.joins("INNER JOIN amenities as am on am.id = amenity_reservations.amenity_id")
		    .joins("INNER JOIN associations ON associations.id = amenity_reservations.association_id")
		    .joins("INNER JOIN amenities ON amenities.id = amenity_reservations.amenity_id")

			if params[:search].present?
				search_term = "%#{params[:search].strip}%"

				# 1st try: filter by association name
				filtered = amenity_reservations.where("associations.name ILIKE ?", search_term)

				amenity_reservations = if filtered.exists?
					filtered
				else
					amenity_reservations.where("amenities.amenity_name ILIKE :search OR amenity_reservations.serial_number_sku ILIKE :search",search: search_term)
				end
			end
			amenity_reservations
		end
	end
end