module V1
	class UnitsController < ApplicationController
		# before_action :set_user
		# before_action :set_association#, only: [:index, :show, :update, :destroy]
		before_action :set_unit, only: [:show, :update, :destroy, :unit_history, :autopay_enabled]
		def index
			begin

				return if set_association_from_params! == :rendered
				units = fetch_units_for_current_user

				# association_id = params[:association_id]
				page = params[:page] || 1
				per_page = params[:per_page] || 10

				units = units.order(created_at: :desc).paginate(page: page, per_page: per_page)

				if params[:export] == "true"
					require 'csv'
					# Ensure folder exists
					export_dir = Rails.root.join("tmp", "exports")
					FileUtils.mkdir_p(export_dir)

					filename = "units_time_#{Time.now.to_i}.csv"
					filepath = export_dir.join(filename)

					CSV.open(filepath, "w", write_headers: true, headers: ["Building Number", "Stree Name", "Unit Number", "Unit Owner", "Dues","Status"]) do |csv|
						units.each do |unit|
							csv << [
								unit&.building_no,
								unit&.full_address,
								unit&.unit_number,
								unit&.ownership_account&.user&.full_name,
								"", #Dues pending
								unit&.status
							]
						end
					end
					# Generate file download URL (adjust to match your domain)
					download_url = "#{ENV['HOA_COMMUNITY_SERVER_URL']}/v1/download_file?filename=#{filename}"
					return render json: {status: 200, success: true, data: {url: download_url}, message: "Export successfully" }, status: :ok
				else
					total_pages = units.total_pages
					return render json: {status: 200, success: true, data: UnitDetailsSerializer.new(units).serializable_hash[:data], pagination_data: { total_pages: total_pages, total_records: units.count}, message: "Unit list"}, status: :ok
				end
			rescue => e
				render json: {status: 500, success: false, data: nil, message: e.message}, status: :internal_server_error
	    end
		end

		def show
			render json: {status: 200, success: true, data: UnitDetailsSerializer.new(@unit).serializable_hash[:data], message: "Unit details"}, status: :ok
		end

		# def create
		# 	begin
		# 		unit = @association.units.new(unit_params)
		# 		if unit.save
		# 			render json: {status: 201, success: true, data: UnitDetailsSerializer.new(unit).serializable_hash[:data], message: "Unit created successfully"}, status: :created
		# 		else
		# 			render json: {status: 422, success: false, data: nil, message: unit.errors.full_messages.join(", ")}, :status => :unprocessable_entity
		# 		end
		# 	rescue StandardError => e
		# 		render json: {status: 500, success: false, data: nil, message: e.message }, :status => :internal_server_error
		# 	end
		# end

		def update
			begin
				if @unit.update(unit_params)
					render json: {status: 200, success: true, data: UnitDetailsSerializer.new(@unit).serializable_hash[:data], message: "Unit updated successfully"}, status: :ok
			  else
			  	render json: {status: 422, success: false, data: nil, message: @unit.errors.full_messages.join(", ")}, :status => :unprocessable_entity
			  end
			rescue ActiveRecord::RecordNotFound => e
				render json: {status: 404, success: false, data: nil, message: e.message }, :status => :not_found
			rescue StandardError => e
				render json: {status: 500, success: false, data: nil, message: e.message }, :status => :internal_server_error
			end
		end

		def destroy
			@unit.destroy
			render json: {status: 200, success: true, data: nil, message: "Unit successfully destroyed."}, status: :ok
		end

		def unit_history
			render json: {status: 200, success: true, data: HistoriesSerializer.new(@unit.versions).serializable_hash[:data], message: "User History"}
		end

		def autopay_enabled
			begin
				# it's will be set and remove on payment gateway
				auto = UnitAutopay.find_or_initialize_by(unit_id: @unit.id, user_id: current_user.id)
				if auto.persisted? && auto.is_active?
					# Already active, so disable it
					auto.is_active = false
					message = "Autopay disabled successfully"
				else
					# Either new record or inactive, so enable it
					auto.is_active = true
					auto.amount = params[:amount] if params[:amount].present?
					auto.payment_method_id = params[:payment_method_id] if params[:payment_method_id].present?
					auto.bank_account_id = params[:bank_account_id] if params[:bank_account_id].present?
					auto.card_ach_fee = params[:card_ach_fee] if params[:card_ach_fee].present?
					auto.total_amount = params[:total_amount] if params[:total_amount].present?
					message = "Autopay enabled successfully"
				end

				if auto.save
					render json: {status: 200, success: true, data: nil, message: message}
				else
					render json: {status: 422, success: false, data: nil, message: auto.errors.full_messages.join(", ")}
				end
			rescue StandardError => e
				render json: {status: 500, success: false, data: nil, message: e.message }
			end
		end

		private
		# def set_user
		# 	#Is current_user
		# 	@user = User.find_by(id: params[:user_id])
		# 	return render json: {errors: {message: ["User not found"]}}, :status => :not_found unless @user.present?
		# end


		# def set_association
		# 	if current_user.has_role?(:SystemAdmin)
		# 		@association = current_user.associations.find_by(id: params[:association_id]) if params[:association_id]
		# 	else
		# 		@association = Association.find_by(id: params[:association_id]) if params[:association_id]
		# 	end
		# 	return render json: {status: 404, success: false, data: nil, message: "Association not found"}, :status => :not_found unless @association.present?
		# end

		def set_unit
			return if set_association_from_params! == :rendered
			units = fetch_units_for_current_user
			@unit = units.find_by(id: params[:id])
			return render json: {status: 404, success: false, data: nil, message: "Unit not found"}, :status => :not_found unless @unit.present?
		end

		# Reusable association setter
		def set_association_from_params!
			return unless params[:association_id].present?

			@association = if current_user.has_role?(:SystemAdmin)
											 current_user.associations.find_by(id: params[:association_id])
										 else
											 Association.find_by(id: params[:association_id])
										 end

			unless @association
				render json: {
					status: 404,
					success: false,
					data: nil,
					message: "Association not found"
				}, status: :not_found
				return :rendered
			end
		end

		# Reusable units fetcher
		def fetch_units_for_current_user
			# if current_user.has_role?(:Resident)
			if current_user.current_role == "Resident"
				if @association
					Unit.joins(:ownership_account).where(
						ownership_accounts: {
							unit_owner_id: current_user.id,
							association_id: @association.id
						}
					)
				else
					Unit.joins(:ownership_account).where(
						ownership_accounts: { unit_owner_id: current_user.id }
					)
				end
			else
				@association ? @association.units : current_user.admin_units
			end
		end



		def unit_params
			params.require(:unit).permit(:name, :unit_number, :state, :city, :zip_code, :street, :building_no, :floor, :unit_bedrooms, :unit_bathrooms, :surface_area, :notice_document, :description,
				ownership_account_attributes: [:id, :unit_owner_id, :first_name, :last_name, :phone_number, :email, :is_owner_association_board_member, :is_tenant_occupies_unit, :tenant_id, :tenant_first_name, :tenant_last_name, :tenant_phone_number, :tenant_email, :date_of_purchase, :inheritance_date],
				unit_financials_attributes: [:id, :amount, :frequency, :start_date, :_destroy],
				unit_files_attributes:[:id, :document, :category_name, :_destroy])
		end
	end
end