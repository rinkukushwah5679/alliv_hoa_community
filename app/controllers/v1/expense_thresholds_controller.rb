module V1
	class ExpenseThresholdsController < ApplicationController
		before_action :set_threshold, only: [:show, :update, :destroy]

		def index
			begin
				return if set_association_from_params! == :rendered
				thresholds = fetch_threshold
				page = params[:page] || 1
				per_page = params[:per_page] || 10
				thresholds = thresholds.order(created_at: :desc).paginate(page: page, per_page: per_page)
				total_pages = thresholds.total_pages
				return render json: {status: 200, success: true, data: ExpenseThresholdSerializer.new(thresholds).serializable_hash[:data], pagination_data: { total_pages: total_pages, total_records: thresholds.count}, message: "thresholds list"}
			rescue StandardError => e
				render json: {status: 500, success: false, data: nil, message: e.message}
			end
		end

		private
		def set_threshold
			return if set_association_from_params! == :rendered
			thresholds = fetch_threshold
			@threshold = thresholds.find_by(id: params[:id])
			return render json: {status: 404, success: false, data: nil, message: "Expense threshold not found"} unless @threshold.present?
		end

		# Reusable association setter
		def set_association_from_params!
			return unless params[:association_id].present?
			@association = Association.find_by(id: params[:association_id])

			unless @association
				render json: {status: 404, success: false, data: nil, message: "Association not found"}, status: :not_found
				return :rendered
			end
		end

		def fetch_threshold
			if @association .present?
				@association.expense_thresholds
			else
			associations = current_user.associations
			ExpenseThreshold.where(association_id: associations.pluck(:id))
			end
		end
	end
end