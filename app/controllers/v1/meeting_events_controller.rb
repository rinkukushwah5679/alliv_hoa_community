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
				return render json: {status: 200, success: true, data: MeetingEventsSerializer.new(events).serializable_hash[:data], pagination_data: { total_pages: total_pages, total_records: events.count}, message: "Events list"}
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
				associations = current_user.associations
				MeetingEvent.where(association_id: associations.select(:id))
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

			meetings
		end
	end
end