module V1
	class MeetingEventsController < ApplicationController
		before_action :set_events, only: [:show, :update, :destroy]

		def index
			begin
				return if set_association_from_params! == :rendered
				events = fetch_meetings
				page = params[:page] || 1
				per_page = params[:per_page] || 10
				events = events.order(created_at: :desc).paginate(page: page, per_page: per_page)
				total_pages = events.total_pages
				return render json: {status: 200, success: true, data: MeetingEventsSerializer.new(events).serializable_hash[:data], total_events: events.count, pagination_data: { total_pages: total_pages, total_records: events.count}, message: "Events list"}
			rescue StandardError => e
				render json: {status: 500, success: false, data: nil, message: e.message}
			end
		end

		def show
			render json: {status: 200, success: true, data: MeetingEventsDetailsSerializer.new(@event).serializable_hash[:data], message: "Details"}
		end

		def create
			begin
				@event = MeetingEvent.new(events_params)
				if @event.save
					render json: {status: 200, success: true, data: MeetingEventsSerializer.new(@event).serializable_hash[:data], message: "Updated successfully."}
				else
					render json: {status: 422, success: false, data: nil, message: @event.errors.full_messages.join(", ")}

				end
			rescue StandardError => e
				render json: {status: 500, success: false, data: nil, message: e.message}
			end
		end

		def update
			begin
				if @event.update(events_params)
					render json: {status: 200, success: true, data: MeetingEventsDetailsSerializer.new(@event).serializable_hash[:data], message: "Updated successfully."}
				else
					render json: {status: 422, success: false, data: nil, message: @event.errors.full_messages.join(", ")}

				end
			rescue StandardError => e
				render json: {status: 500, success: false, data: nil, message: e.message}
			end
		end

		def destroy
			@event.destroy
			render json: {status: 200, success: true, data: nil, message: "Event successfully destroyed."}
		end

		private

		def events_params
			params.require(:events).permit(:association_id, :title, :description, :meeting_type, :user_id, :unit_number, :meeting_date, :start_time, :end_time, :location, :address, :latitude, :longitude, :participants, event_attachments: [])
		end

		def set_events
			@event = MeetingEvent.select("meeting_events.*, a.id AS a_id, a.name AS a_name").joins("INNER JOIN associations as a on a.id = meeting_events.association_id").find_by(id: params[:id])
			return render json: {status: 404, success: false, data: nil, message: "Event not found"} unless @event.present?
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

		def fetch_meetings
			meetings = if @association.present?
				@association.meeting_events
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
				    when "BoardMember", "SystemAdmin"
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
				# MeetingEvent.where(association_id: associations.select(:id))
				if current_user.current_role == "Resident"
					MeetingEvent.where(association_id: associations.map(&:id), participants: "All Members")
				else
					MeetingEvent.where(association_id: associations.map(&:id))
				end
			end
			meetings = meetings.joins("INNER JOIN associations ON associations.id = meeting_events.association_id")

			if params[:search].present?
				search_term = "%#{params[:search]}%"

				# 1st try: filter by association name
				filtered = meetings.where("associations.name ILIKE ?", search_term)

				# if no results → fallback to approval_type
				meetings = if filtered.exists?
					filtered
				else
					meetings.where("meeting_events.title ILIKE :search OR meeting_type ILIKE :search OR location ILIKE :search",search: search_term)
				end
			end

			# meetings
			if params[:dashboard].present?
				current_time = Time.zone.now
				meetings = meetings.where("meeting_date > ? OR (meeting_date = ? AND start_time >= ?)",
                                   current_time.to_date, current_time.to_date, current_time)
			else
				meetings = meetings
			end
			meetings
		end
	end
end