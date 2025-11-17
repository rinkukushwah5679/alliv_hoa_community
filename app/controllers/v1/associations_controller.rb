module V1
	class AssociationsController < ApplicationController
		# before_action :set_user
		before_action :set_association, only: [:show, :update, :destroy] #create_stripe_account
		def index
			begin
				# associations = Association
				#   .left_joins(units: :ownership_account)
				#   .left_joins(:community_association_managers)
				#   .where(
				#     "ownership_accounts.unit_owner_id = :user_id OR community_association_managers.user_id = :user_id OR associations.property_manager_id =  :user_id",
				#     user_id: current_user.id
				#   )
				#   .yield_self { |query|
				#     # params[:search].present? ? query.where("associations.name ILIKE ?", "%#{params[:search]}%") : query
				#     query = query.where("associations.name ILIKE ?", "%#{params[:search]}%") if params[:search].present?
				#     query = query.where(status: params[:status]) if params[:status].present?
				#     query
				#   }
				#   .distinct
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

				    # filters
				    query = query.where("associations.name ILIKE ?", "%#{params[:search]}%") if params[:search].present?
				    query = query.where(status: params[:status]) if params[:status].present?
				    query
				  }
				  .distinct
				  .paginate(page: (params[:page] || 1), per_page: (params[:per_page] || 10))
				# if current_user.has_role?(:Resident)
				# 	associations = Association.joins(units: :ownership_account).where(ownership_accounts: { unit_owner_id: current_user.id }).distinct.paginate(page: (params[:page] || 1), per_page: (params[:per_page] || 10))
				# elsif current_user.has_role?(:AssociationManager)
				# 	associations = Association.joins(:community_association_managers).where(community_association_managers: { user_id: current_user.id }).distinct.paginate(page: (params[:page] || 1), per_page: (params[:per_page] || 10))
				# else
				# 	associations = current_user.associations.order("created_at DESC").paginate(page: (params[:page] || 1), per_page: (params[:per_page] || 10))
				# end
				total_pages = associations.present? ? associations.total_pages : 0
				render json: {status: 200, success: true, data: AssociationsListSerializer.new(associations).serializable_hash[:data], pagination_data: {total_pages: total_pages, total_records: associations.count}, message: "Association list"}, status: :ok
			rescue => e
				render json: {status: 500, success: false, data: nil, message: e.message}, status: :internal_server_error
	    end
		end

		def show
			# render json: AssociationsSerializer.new(@association, meta: {message: "Association details"}).serializable_hash, status: :ok
			render json: {status: 200, success: true, data: AssociationsSerializer.new(@association).serializable_hash[:data], message: "Association details"}, status: :ok
		end

		def create
			begin
			  association = current_user.associations.new(association_params)
			  if association.save
					bank_accounts = create_stripe_bank_account(association)
			  	# create_stripe_account_id(association)
			    render json: {status: 201, success: true, data: AssociationsSerializer.new(association).serializable_hash[:data], failed_bank_accounts: bank_accounts, message: "Association created successfully"}, status: :created
			  else
			    render json: {status: 422, success: false, data: nil, message: association.errors.full_messages.join(", ")}, :status => :unprocessable_entity
			  end
		  rescue StandardError => e
				render json: {status: 500, success: false, data: nil, message: e.message }, :status => :internal_server_error
			end
		end

		def update
			begin
				if @association.update(association_params)
					bank_accounts = create_stripe_bank_account(@association)
					# render json: AssociationsSerializer.new(@association, meta: { message: "Association updated successfully"}), status: :ok
					render json: {status: 200, success: true, data: AssociationsSerializer.new(@association).serializable_hash[:data], failed_bank_accounts: bank_accounts, message: "Association updated successfully"}, status: :ok
			  else
			    # render json: { errors: @association.errors.full_messages.join(", ") }, status: :unprocessable_entity
			    render json: {status: 422, success: false, data: nil, message: @association.errors.full_messages.join(", ")}, :status => :unprocessable_entity
			  end
			rescue ActiveRecord::RecordNotFound => e
				# render json: { errors: e.message }, status: :not_found
				render json: {status: 404, success: false, data: nil, message: e.message }, :status => :not_found
			rescue StandardError => e
				# render json: {errors: e.message}, status: :internal_server_error
				render json: {status: 500, success: false, data: nil, message: e.message }, :status => :internal_server_error
			end
		end

		def destroy
			@association.destroy
	    # render json: {message:"Association successfully destroyed."}, status: :ok
	    render json: {status: 200, success: true, data: nil, message: "Association successfully destroyed."}, status: :ok
		end

		def create_stripe_account
	    return if test_environment?
	    begin
	    	# Standard accounts are fully managed by Stripe dashboard
		    # self.stripe_account_id = Stripe::Account.create({type: 'standard', email: self.email, country: 'US',})['id']
		    return render json: { status: 422, success: false, data: nil, message: "Please choose ID"}, status: :unprocessable_entity unless params[:identity_document].present?
		    uploaded_file = params[:identity_document].tempfile
				# file = Stripe::File.create({
				# 	purpose: 'identity_document',
				# 	file: File.new('/home/arvind/Desktop/photos/card-driving.jpg')
				# })

				file = Stripe::File.create({
					purpose: 'identity_document',
					file: uploaded_file
				})
		    ass_owner = @association.user
		    dob = ass_owner.dob
		    if dob.present?
		      day = dob.strftime("%d")
		      month = dob.strftime("%m")
		      year = dob.strftime("%Y")
		    else
		      day = "01"
		      month = "01"
		      year = "1990"
		    end
		    account = Stripe::Account.create({
		      type: 'custom',
		      country: 'US',
		      email: @association.email,
		      business_type: 'individual',
		      individual: {
		        first_name: ass_owner.first_name,
		        last_name: ass_owner.last_name,
		        email: ass_owner.email,
		        phone: ass_owner.phone_number.present? ? ass_owner.phone_number : '+15551234567',
		        dob: { day: day, month: month, year: year },
		        ssn_last_4: '6789', # Social Security Number
		        verification: {
			        document: { front: file.id } # Use `file.id` from previous step
			      },
		      },
		      business_profile: {
		        mcc: '5734',  # Merchant Category Code
		        url: 'https://www.bitterntec.com/'
		      },
		      capabilities: { transfers: { requested: true } },
		      tos_acceptance: { date: Time.now.to_i, ip: request.remote_ip },
					external_account: {
						object: 'bank_account',
						country: 'US',
						currency: 'usd',
						routing_number: '110000000',
						account_number: '000123456789',
						account_holder_name: ass_owner.full_name,
						account_holder_type: 'individual'
					}
		    })
		    if account.payouts_enabled
			    # @association.stripe_account_id = account.id
			    # @association.is_payout_enabled = true
			    # @association.save
			    @association.update_column(:is_payout_enabled, true)
			    return render json: {status: 200, success: true, data: AssociationsSerializer.new(@association).serializable_hash[:data], message: "Payout successfully Enabled"}, status: :ok
			  else
			  	@association.update_column(:stripe_account_id, account.id)
			  	return render json: {status: 422, success: false, data: nil, message:"Pending Details #{account.requirements.currently_due.join(', ')}"}
		    end
	    rescue Stripe::StripeError => e
	    	return render json: { status: 422, success: false, data: nil, message: e.message}, status: :unprocessable_entity
	    rescue StandardError => e
				# render json: {errors: e.message}, status: :internal_server_error
				render json: {status: 500, success: false, data: nil, message: e.message }, :status => :internal_server_error
	    end
	  end


		private
		def association_params
			params.require(:association).permit(:name, :telephone_no, :email, :web_url, :is_active, :status,
			association_address_attributes: [:id, :street, :building_no, :zip_code, :state, :city, :_destroy],
			bank_accounts_attributes: [:id, :account_purpose, :name, :description, :bank_account_type, :account_number, :routing_number, :is_active, :_destroy],
	    association_dues_attributes: [:id, :distribution_type, :amount, :frequency, :start_date, :end_date, :due_type, :title, :_destroy],
	    association_late_payment_fee_attributes: [:id, :amount, :frequency],
	    special_assesments_attributes: [:id, :distribution_type, :amount, :frequency, :start_date, :end_date, :due_type, :title, :_destroy],
	    tax_information_attributes: [:id, :tax_payer_type, :tax_payer_id],
	    community_association_managers_attributes: [:id, :user_id, :_destroy],
	    units_attributes: [:id, :name, :unit_number, :state, :city, :zip_code, :street, :building_no, :floor, :unit_bedrooms, :unit_bathrooms, :surface_area, :notice_document, :description, :_destroy, ownership_account_attributes: [:id, :unit_owner_id, :first_name, :last_name, :phone_number, :email, :is_owner_association_board_member, :is_tenant_occupies_unit, :tenant_id, :tenant_first_name, :tenant_last_name, :tenant_phone_number, :tenant_email, :date_of_purchase, :inheritance_date],
				unit_financials_attributes: [:id, :amount, :frequency, :start_date, :_destroy],
				unit_files_attributes:[:id, :document, :category_name, :_destroy]],
			expense_thresholds_attributes: [:id, :amount, :status, :approval_type, :_destroy],
			voting_rules_attributes: [:id, :participant_category, :ratification_type, :status, :_destroy]

			)
		end

		

		def set_user
			#Is current_user
			@user = User.find_by(id: params[:user_id])
			return render json: {status: 404, success: false, data: nil, message: "User not found"}, :status => :not_found unless @user.present?
		end

		def set_association
			# @association = current_user.associations.find_by_id(params[:id]) if params[:id]
			@association = Association.find_by_id(params[:id]) if params[:id]
			# return render json: {errors: {message: ["Association not found"]}}, :status => :not_found unless @association.present?
			return render json: {status: 404, success: false, data: nil, message: "Association not found"}, :status => :not_found unless @association.present?
			# return render json: {errors: "Association not found"}, :status => :not_found unless @association.present?
		end

		def test_environment?
			Rails.env.test?
		end

		def create_stripe_bank_account(association)
			failed_accounts = []

      association.bank_accounts.where(stripe_bank_account_id:[nil, ""]).each do |bank_account|
        begin
					unless association.stripe_account_id.present?
						stripe_account_id = Stripe::Account.create({
							type: 'custom',
							country: 'US',
							email: association.email,
							capabilities: { transfers: { requested: true } },
							business_type: 'individual'
						})['id']
						association.update!(stripe_account_id: stripe_account_id)
					end
          stripe_bank_account = Stripe::Account.create_external_account(
            association.stripe_account_id,
            {
              external_account: {
                object: "bank_account",
                country: bank_account.country || "US",
                currency: "usd",
                account_holder_name: bank_account.recipient_name || association.name,
                account_holder_type: "individual",
                routing_number: bank_account.routing_number,
                account_number: bank_account.account_number
              }
            }
          )
          bank_account.update(stripe_bank_account_id: stripe_bank_account.id, is_verified: true)
        rescue Stripe::StripeError => e
          bank_account.update(is_verified: false)
          failed_accounts << {
            id: bank_account.id,
            name: bank_account.name,
            account_number: bank_account.account_number,
            routing_number: bank_account.routing_number,
            error: e.message
          }
        end
      end
      failed_accounts
		end

	  # def create_stripe_account_id(association)
	  #   return if test_environment?
	  #   # Standard accounts are fully managed by Stripe dashboard
	  #   # self.stripe_account_id = Stripe::Account.create({type: 'standard', email: self.email, country: 'US',})['id']
	  #   file = Stripe::File.create({
	  #     purpose: 'identity_document',
	  #     file: File.new('/home/arvind/Desktop/photos/card-driving.jpg')
	  #   })

	  #   ass_owner = association.user
	  #   dob = ass_owner.dob
	  #   if dob.present?
	  #     day = dob.strftime("%d")
	  #     month = dob.strftime("%m")
	  #     year = dob.strftime("%Y")
	  #   else
	  #     day = "01"
	  #     month = "01"
	  #     year = "1990"
	  #   end
	  #   association.stripe_account_id = Stripe::Account.create({
	  #     type: 'custom',
	  #     country: 'US',
	  #     email: association.email,
	  #     business_type: 'individual',
	  #     individual: {
	  #       first_name: ass_owner.first_name,
	  #       last_name: ass_owner.last_name,
	  #       email: ass_owner.email,
	  #       phone: ass_owner.phone_number.present? ? ass_owner.phone_number : '+15551234567',
	  #       dob: { day: day, month: month, year: year },
	  #       ssn_last_4: '6789', # Social Security Number
	  #       verification: {
	  #       document: { front: file.id } # Use `file.id` from previous step
	  #     },
	  #     },
	  #     business_profile: {
	  #       mcc: '5734',  # Merchant Category Code
	  #       url: 'https://www.bitterntec.com/'
	  #     },
	  #     capabilities: { transfers: { requested: true } },
	  #     tos_acceptance: { date: Time.now.to_i, ip: request.remote_ip }
	  #   })['id']
	  #   association.save

	  #   # if bank_accounts.present?
	  #   #   bank_accounts
	  #   # end
	  # end
	end
end