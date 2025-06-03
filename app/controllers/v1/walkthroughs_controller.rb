module V1
	class WalkthroughsController < ApplicationController
		before_action :set_association
		before_action :set_walkthrough, only: [:show, :update, :destroy]

		def index
			walkthroughs = @association.walkthroughs.order("created_at DESC").paginate(page: (params[:page] || 1), per_page: (params[:per_page] || 10))
			total_pages = walkthroughs.present? ? walkthroughs.total_pages : 0
			render json: {status: 201, success: true, data: WalkthroughsSerializer.new(walkthroughs).serializable_hash[:data], pagination_data: {total_pages: total_pages, total_records: walkthroughs.count}, message: "Walkthroughs list"}, :status => :ok
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
			@association = Association.find_by_id(params[:association_id]) if params[:association_id]
			return render json: {status: 404, success: false, data: nil, message: "Association not found"}, :status => :not_found unless @association.present?
		end

		def set_walkthrough
			@walkthrough = Walkthrough.find_by_id(params[:id]) if params[:id]
			return render json: {status: 404, success: false, data: nil, message: "Walkthrough not found"}, :status => :not_found unless @walkthrough.present?
		end
	end
end