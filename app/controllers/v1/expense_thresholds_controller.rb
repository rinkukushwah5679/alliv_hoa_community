module V1
	class ExpenseThresholdsController < ApplicationController
		before_action :set_threshold, only: [:show, :update, :destroy]

		def index
			begin
				return if set_association_from_params! == :rendered
				thresholds = fetch_threshold
				page = params[:page] || 1
				per_page = params[:per_page] || 10
				thresholds = thresholds.select("expense_thresholds.*, a.id AS a_id, a.name AS a_name").joins("INNER JOIN associations as a on a.id = expense_thresholds.association_id").order(created_at: :desc).paginate(page: page, per_page: per_page)
				total_pages = thresholds.total_pages
				return render json: {status: 200, success: true, data: ExpenseThresholdSerializer.new(thresholds).serializable_hash[:data], pagination_data: { total_pages: total_pages, total_records: thresholds.count}, message: "thresholds list"}
			rescue StandardError => e
				render json: {status: 500, success: false, data: nil, message: e.message}
			end
		end

		def show
			render json: {status: 200, success: true, data: ExpenseThresholdSerializer.new(@threshold).serializable_hash[:data], message: "Details"}
		end

		def update
			begin
				if @threshold.update(threshold_params)
					render json: {status: 200, success: true, data: ExpenseThresholdSerializer.new(@threshold).serializable_hash[:data], message: "Updated successfully."}
				else
					render json: {status: 422, success: false, data: nil, message: @threshold.errors.full_messages.join(", ")}

				end
			rescue StandardError => e
				render json: {status: 500, success: false, data: nil, message: e.message}
			end
		end

		def destroy
			@threshold.destroy
			render json: {status: 200, success: true, data: nil, message: "Thresholds successfully destroyed."}
		end

		private

		def threshold_params
			params.require(:threshold).permit(:status)
		end

		def set_threshold
			# return if set_association_from_params! == :rendered
			# thresholds = fetch_threshold
			@threshold = ExpenseThreshold.select("expense_thresholds.*, a.id AS a_id, a.name AS a_name").joins("INNER JOIN associations as a on a.id = expense_thresholds.association_id").find_by(id: params[:id])
			# @threshold = ExpenseThreshold.find_by(id: params[:id])
			return render json: {status: 404, success: false, data: nil, message: "Expense threshold not found"} unless @threshold.present?
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

		def fetch_threshold
			thresholds = if @association.present?
				@association.expense_thresholds
			else
				associations = current_user.associations
				ExpenseThreshold.where(association_id: associations.select(:id))
			end
			thresholds = thresholds.joins("INNER JOIN associations ON associations.id = expense_thresholds.association_id")

			if params[:search].present?
				search_term = "%#{params[:search]}%"

				# 1st try: filter by association name
				filtered = thresholds.where("associations.name ILIKE ?", search_term)

				# if no results → fallback to approval_type
				thresholds = if filtered.exists?
					filtered
				else
					thresholds.where("expense_thresholds.approval_type ILIKE ?", search_term)
				end
			end

			thresholds
		end
	end
end