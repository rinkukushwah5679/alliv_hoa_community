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
				per_page_value = Setting.per_page_records
				per_page = params[:per_page] || per_page_value

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
					return render json: {status: 422, success: false, data: nil, message: "Please choose bank account"} unless params[:payment_method_id].present?
					# Either new record or inactive, so enable it
					auto.is_active = true
					auto.amount = params[:amount] if params[:amount].present?
					auto.payment_method_id = params[:payment_method_id] if params[:payment_method_id].present? #this is bank id
					# auto.bank_account_id = params[:bank_account_id] if params[:bank_account_id].present? #Removed thid column bank_account_id
					# auto.card_ach_fee = params[:card_ach_fee] if params[:card_ach_fee].present?
					auto.total_dues = params[:total_dues]
					auto.convenience_fee = params[:ach_convenience_fee]
					auto.total_amount = params[:total_amount]
					auto.unityfi_ach_monthly_fee = params[:unityfi_ach_monthly_fee]
					auto.association_due_id = params[:association_due_id]
					auto.due_date = params[:due_date]
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

		def import
			begin
				association = Association.find_by_id(params[:association_id]) if params[:association_id]
				return render json: {status: 404, success: false, data: nil, message: "Association not found"} unless association.present?

				if current_user.current_role == "SystemAdmin"
					subs = current_user.active_subscription
				  unless subs.present?
						return render json: {status: 422, success: false, data: nil, message: "You have no active subscription." }
				  end

					if subs.end_date.blank? || subs.end_date <= Time.current
						return render json: {status: 422, success: false, data: nil, message: "Your subscription has expired." }
					end
					total_units = subs&.units || 0
					used_units = Unit.joins(:custom_association).where(associations: { property_manager_id: current_user.id }).count
					unused_units = total_units - used_units
					unused_units = unused_units.negative? ? 0 : unused_units
				else #For AssociationManager
					user = association.user
					subs = user.active_subscription
				  unless subs.present?
						return render json: {status: 422, success: false, data: nil, message: "Your association owner's subscription is not active." }
				  end

				  if subs.end_date.blank? || subs.end_date <= Time.current
						return render json: {status: 422, success: false, data: nil, message: "Your association owner's subscription has expired." }
					end
					total_units = subs&.units || 0
					used_units = Unit.joins(:custom_association).where(associations: { property_manager_id: user.id }).count
					unused_units = total_units - used_units
					unused_units = unused_units.negative? ? 0 : unused_units

				end

				file = params[:file]
	  		return render json: {status: 422, success: false, data: nil, message: "File is required" } if file.blank?
	  		extension = File.extname(file.original_filename).downcase

	  		unless %w[.csv .xlsx].include?(extension)
			    return render json: {status: 422, success: false, data: nil, message: "Only CSV and XLSX files are allowed" }
			  end
			  required_headers = ["Unit Number", "Building No", "Floor", "No. of Bathrooms", "No. of Bedrooms", "Surface(ft2)", "Street", "City", "State/Province", "ZIP/Postal"]
			  valid_units   = []
				invalid_units = []
				# unused_units = 5
			  if extension == ".csv"
					if CSV.read(params[:file].path).empty? || CSV.read(params[:file].path)[0].empty?
		        return render json: {status: 422, success: false, data: nil, message: 'CSV file is empty.' }
		      end

		      rows = CSV.read(file.path, headers: true)
		      # Header check
					unless (required_headers - rows.headers).empty?
					  return render json: {status: 422, success: false, data: nil, message: 'Invalid headers' }
					end
		      return render json: {status: 422, success: false, data: nil, message: "No records in CSV" } if rows.empty?

		      # Count only non-empty rows
	  			csv_unit_count = rows.count { |r| r.to_h.values.any?(&:present?) }

					if csv_unit_count > unused_units
						return render json: {status: 422, success: false, data: nil, message: "You have only #{unused_units} unused units. You can create only #{unused_units} units."}
					end

					CSV.foreach(file.path, headers: true) do |row|
						unit = Unit.new(unit_number: row[0].to_i, building_no: row[1], floor: row[2], unit_bathrooms: row[3], unit_bedrooms: row[4], surface_area: row[5], street: row[6], city: row[7], state: row[8], zip_code: row[9], association_id: association.id)
						if unit.save
							valid_units << unit
						else
							invalid_units << {
					      row_data: row.to_hash,
					      error: unit.errors.full_messages.join(", ")
					    }
						end
					end
	  		elsif extension == ".xlsx"
				  workbook = RubyXL::Parser.parse(file.path)
				  sheet = workbook[0]

				  # Header check
				  header_row = sheet[0]
				  # headers = header_row&.cells&.map(&:value)&.compact
				  headers = header_row&.cells&.map { |c| c&.value }&.compact


				  if headers.blank?
				    return render json: {status: 422, success: false, data: nil, message: "XLSX file is empty"
				    }
				  end

				  # Count only non-empty data rows
				  xlsx_unit_count = 0

				  sheet.each_with_index do |row, index|
				    next if index.zero? # skip header
				    # values = row&.cells&.map(&:value)&.compact
				    values = row&.cells&.map { |c| c&.value }&.compact
				    next if values.blank?

				    xlsx_unit_count += 1
				  end

				  # NEW CHECK — only header, no data
				  if xlsx_unit_count.zero?
				    return render json: {status: 422, success: false, data: nil, message: "No records found in XLSX file."}
				  end
				  headers = sheet[0]&.cells&.map { |c| c&.value.to_s.strip }

					missing_headers = required_headers - headers

					if missing_headers.any?
					  return render json: {status: 422, success: false, data: nil, message: "Invalid XLSX headers. Please upload the correct sample file."}
					end
				  # unused_units = 2
				  # Subscription limit check
				  if xlsx_unit_count > unused_units
				    return render json: {status: 422, success: false, data: nil, message: "You have only #{unused_units} unused units. You can create only #{unused_units} units."
				    }
				  end

				  sheet.each_with_index do |row, index|
					  next if index.zero?

					  # values1 = row&.cells&.map(&:value)
					  # values = row&.cells&.map { |c| c&.value }&.compact
					  values = row&.cells&.map { |c| c&.value }
					  next if values.blank?
					  data = headers.zip(values).to_h
					  unit = Unit.new(unit_number: values[0], building_no: values[1], floor: values[2], unit_bathrooms: values[3], unit_bedrooms: values[4], surface_area: values[5], street: values[6], city: values[7], state: values[8], zip_code: values[9], association_id: association.id)

					  if unit.save
					    valid_units << unit
					  else
					    invalid_units << {
					      row_data: data,
					      error: unit.errors.full_messages.join(", ")
					    }
					  end
					end
	  		else
	  			return render json: {status: 422, success: false, data: nil, message: "Only CSV and XLSX files are allowed" }
		    end
				invalid_file_url = nil
				if invalid_units.present?
					timestamp = Time.current.to_i
					# invalid_file_url = generate_invalid_csv(invalid_units, required_headers, timestamp)
					invalid_file_url =
				    if extension == ".csv"
				      generate_invalid_csv(invalid_units, required_headers, timestamp)
				    else
				      generate_invalid_xlsx(invalid_units, required_headers, timestamp)
				    end
				end
				return render json: {
				  status: 201,
				  success: true,
				  data: {
						created_units: valid_units.size,
						failed_units: invalid_units.size,
						invalid_file_url: invalid_file_url
				  },
				  message: "Units are imported successfully."
				}
		  rescue StandardError => e
				Rails.logger.info "********** #{e.message} **********"
				render json: {status: 500, success: false, data: nil, message: e.message }
			end
		end

		private

		def generate_invalid_csv(invalid_units, required_headers, timestamp)
			export_dir = Rails.root.join("tmp", "exports")
			FileUtils.mkdir_p(export_dir)

			filename = "invalid_units_#{timestamp}.csv"
			filepath = export_dir.join(filename)

		  CSV.open(filepath, "wb") do |csv|
		    csv << (required_headers + ["Error"])

		    invalid_units.each do |row|
		      csv << required_headers.map { |h| row[:row_data][h] } + [row[:error]]
		    end
		  end

		  "#{ENV["HOA_COMMUNITY_SERVER_URL"]}/v1/download_file?filename=#{filename}"
		end

		def generate_invalid_xlsx(invalid_units, required_headers, timestamp)
			export_dir = Rails.root.join("tmp", "exports")
			FileUtils.mkdir_p(export_dir)

			filename = "invalid_units_#{timestamp}.xlsx"
			filepath = export_dir.join(filename)
		  workbook = RubyXL::Workbook.new
		  sheet = workbook[0]
			# ===== HEADER ROW =====
		  required_headers.each_with_index do |header, col|
		    sheet.add_cell(0, col, header)
		  end
		  sheet.add_cell(0, required_headers.size, "Error")
		  invalid_units.each_with_index do |row, row_index|
		    required_headers.each_with_index do |header, col|
		      sheet.add_cell(
		        row_index + 1,
		        col,
		        row[:row_data][header.to_s]
		      )
		    end

		    sheet.add_cell(
		      row_index + 1,
		      required_headers.size,
		      row[:error].to_s
		    )
		  end
		  # path = Rails.root.join("public/invalid_units/invalid_units_#{timestamp}.xlsx")
		  workbook.write(filepath)

		  "#{ENV["HOA_COMMUNITY_SERVER_URL"]}/v1/download_file?filename=#{filename}"
		end

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
					units = Unit.joins(:ownership_account).where(
						ownership_accounts: {
							unit_owner_id: current_user.id,
							association_id: @association.id
						}
					)
				else
					units = Unit.joins(:ownership_account).where(
						ownership_accounts: { unit_owner_id: current_user.id }
					)
				end
			else

				units = if @association.present?
					@association.units
				else
					associations = Association
					  .left_joins(:community_association_managers)
					  .yield_self { |query|
					    case current_user.current_role
					    when "AssociationManager"
					      query = query.where("community_association_managers.user_id = ?", current_user.id)
					    else# "BoardMember", "SystemAdmin"
					      query = query.where("associations.property_manager_id = ?", current_user.id)
					    end
					    query
					  }
					  .distinct
					association_ids = associations.map(&:id)
					Unit.where(association_id: association_ids)
				end
				# units = @association ? @association.units : current_user.admin_units
			end
			units
		end



		def unit_params
			params.require(:unit).permit(:name, :unit_number, :state, :city, :zip_code, :street, :building_no, :floor, :unit_bedrooms, :unit_bathrooms, :surface_area, :notice_document, :description,
				ownership_account_attributes: [:id, :unit_owner_id, :first_name, :last_name, :phone_number, :email, :is_owner_association_board_member, :is_tenant_occupies_unit, :tenant_id, :tenant_first_name, :tenant_last_name, :tenant_phone_number, :tenant_email, :date_of_purchase, :inheritance_date],
				unit_financials_attributes: [:id, :amount, :frequency, :start_date, :_destroy],
				unit_files_attributes:[:id, :document, :category_name, :_destroy])
		end
	end
end