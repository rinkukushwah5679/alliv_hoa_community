module V1
	class BankAccountsController < ApplicationController
		before_action :set_bank, only: [:show, :destroy, :update]
		# rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity_response
		def index
			begin
				bank_accounts = BankAccount.all

				if params[:filter] == 'mine'
					bank_accounts = bank_accounts.for_current_user(current_user)
				elsif params[:association_id].present?
					bank_accounts = bank_accounts.for_specific_association(params[:association_id])
				else
					association_ids = current_user.associations.pluck(:id)
					bank_accounts = bank_accounts.for_association_ids(association_ids)
				end
				totle_balance = bank_accounts.present? ? bank_accounts.sum(:available_balance).to_f : 0.0
				bank_accounts = bank_accounts.paginate(page: (params[:page] || 1), per_page: (params[:per_page] || 10))
				# bank_accounts = current_user.bank_accounts.paginate(page: (params[:page] || 1), per_page: (params[:per_page] || 10))
				total_pages = bank_accounts.present? ? bank_accounts.total_pages : 0
				render json: {status: 200, success: true, data: BankAccountSerializer.new(bank_accounts).serializable_hash[:data], totle_balance: totle_balance, pagination_data: {total_pages: total_pages, total_records: bank_accounts.count}, message: "Bank Account list"}, status: :ok
			rescue StandardError => e
				render json: {status: 500, success: false, data: nil, message: e.message }, :status => :internal_server_error
			end
		end

		def show
			render json: {status: 200, success: true, data: BankAccountSerializer.new(@bank_account).serializable_hash[:data], message: "Bank details"}, status: :ok
		end

		def create
			begin
				BankAccount.transaction do
					bank_account = current_user.bank_accounts.new(bank_account_params)
					# if bank_account.save
					# 	return render json: {status: 201, success: true, data: BankAccountSerializer.new(bank_account).serializable_hash[:data], message: "Bank Account created successfully"}, status: :created
					# else
					# 	return render json: {status: 422, success: false, data: nil, message: bank_account.errors.full_messages.join(", ")}, :status => :unprocessable_entity
					# end
					bank_account.save!

					# Stripe Bank Account Creation
					# stripe_account_id = current_user.stripe_account_id
					# raise "Stripe account not found" unless stripe_account_id.present?

					stripe_bank_account = Stripe::Account.create_external_account(
						current_user.stripe_account_id,
						{
							external_account: {
								object: "bank_account",
								country: bank_account.country || "US",
								currency: "usd",
								account_holder_name: bank_account.recipient_name,
								account_holder_type: "individual",
								routing_number: bank_account.routing_number,
								account_number: bank_account.account_number
							}
						}
					)
					bank_account.update!(stripe_bank_account_id: stripe_bank_account.id, is_verified: true)

					render json: {status: 201, success: true, data: BankAccountSerializer.new(bank_account).serializable_hash[:data], message: "Bank Account created successfully"}, status: :created
				end
			rescue ActiveRecord::RecordInvalid => e
				render_unprocessable_entity_response(e)
			rescue Stripe::StripeError => e
				Rails.logger.error("Stripe Error: #{e.message}")
				render json: {status: 422, success: false, data: nil, message: friendly_stripe_error(e)}, status: :unprocessable_entity
			rescue StandardError => e
				render json: {status: 500, success: false, data: nil, message: e.message }, :status => :internal_server_error
			end
		end

		# The update request is skipped as there is no update request on QuickBooks
		def update
			begin
				if @bank_account.update(bank_account_params)
					render json: {status: 200, success: true, data: BankAccountSerializer.new(@bank_account).serializable_hash[:data], message: "Bank Account updated successfully"}, status: :ok
			  else
			    render json: {status: 422, success: false, data: nil, message: @bank_account.errors.full_messages.join(", ")}, :status => :unprocessable_entity
			  end
			rescue StandardError => e
				render json: {status: 500, success: false, data: nil, message: e.message }, :status => :internal_server_error
			end
		end

		def destroy
			@bank_account.destroy
			render json: {status: 200, success: true, data: nil, message: "Bank Account successfully destroyed."}, status: :ok
		end

		def create_bank_account
			begin
				# bank = BankAccount.find_by_id(params[:bank_id]) if params[:bank_id]

				accountable_object = params[:bank_accountable_type].camelize.constantize.find_by(id: params[:bank_accountable_id].to_s)
				return render json: {status: 422, success: false, data: nil, message: "#{params[:bank_accountable_type].camelize.constantize} not found"} unless accountable_object.present?
				# unless accountable_object.stripe_account_id.present?
				# 	stripe_account_id = Stripe::Account.create({
				# 		type: 'custom',
				# 		country: 'US',
				# 		email: accountable_object.email,
				# 		capabilities: { transfers: { requested: true } },
				# 		business_type: 'individual'
				# 	})['id']
				# 	accountable_object.update_column(:stripe_account_id, stripe_account_id)
				# end
				public_token = params[:public_token].to_s

				response = HTTParty.post("#{ENV['PLAID_URL']}/item/public_token/exchange", {
					headers: { 'Content-Type' => 'application/json' },
					body: {
						client_id: ENV["PLAID_CLIENT_ID"],
						secret: ENV["PLAID_SECRET"],
						public_token: public_token
					}.to_json
				})
				data = JSON.parse(response.body)
				return render json: {status: 422, success: false, data: nil, message: data["error_message"]} if data.include?("error_code")
				access_token = data["access_token"]
				# access_token = "access-sandbox-84e7b618-36da-4cb7-8de5-416e6ae7392d"
				# bank_account_id = "jv14lyBVkJiE5vma8VL6CDWePv7Q7Wc69yjZq"
				return render json: {status: 422, success: false, data: nil, message: "Access token not valid"} unless access_token.present?

				accounts_response = HTTParty.post("#{ENV['PLAID_URL']}/auth/get", {
					headers: { 'Content-Type' => 'application/json' },
					body: {
						client_id: ENV["PLAID_CLIENT_ID"],
						secret: ENV["PLAID_SECRET"],
						access_token: access_token
					}.to_json
				})

				plaid_bank_accounts = accounts_response["accounts"]
				ach = accounts_response["numbers"]["ach"]
				plaid_bank_accounts.each do |ba|
					account_id = ba["account_id"]
					acc_routing_number = ach.select { |aa| aa["account_id"] == account_id}.first
					bank = accountable_object.reload.bank_accounts.new
					bank.name = accounts_response["item"]["institution_name"] rescue "Test"# "Bank of America"
					bank.bank_account_type = ba["subtype"]
					bank.account_number = acc_routing_number["account"]
					bank.routing_number = acc_routing_number["routing"]
					bank.recipient_name = current_user&.full_name
					bank.recipient_address = current_user&.address
					bank.access_token = access_token
					bank.geteway_account_id = ba["account_id"]
					bank.available_balance = ba["balances"]["available"].to_f rescue 0.0
					bank.current_balance = ba["balances"]["current"].to_f rescue 0.0
					bank.iso_currency_code = ba["balances"]["iso_currency_code"] rescue ""
					bank.limit = ba["balances"]["limit"] rescue ""
					bank.unofficial_currency_code = ba["balances"]["unofficial_currency_code"] rescue ""
					bank.holder_category = ba["holder_category"]
					bank.mask = ba["mask"]
					bank.plaid_name = ba["name"]
					bank.official_name = ba["official_name"]
					bank.subtype = ba["subtype"]
					bank.plaid_type = ba["type"]
					bank.geteway_account_res = accounts_response
					bank.save
					# bank.update_columns(is_verified: true)
					# create_stripe_bank_account_with_plaid(accountable_object, bank)
					create_funding_account_unityfi(accountable_object, bank)
				end
				if accountable_object.class.name == "Association"
					render json: {status: 200, success: true, data: AssociationsSerializer.new(accountable_object).serializable_hash[:data], message: "Successfuly Added"}, status: :ok
				else
					bank_accounts = current_user.bank_accounts
					render json: {status: 200, success: true, data: BankAccountSerializer.new(bank_accounts).serializable_hash[:data], message: "Successfuly Added"}, status: :ok
				end
			rescue StandardError => e
				render json: {status: 500, success: false, data: nil, message: e.message }
			end
		end

		#For plaid
		def create_stripe_bank_account_with_plaid(accountable_object, bank)
			Rails.logger.info " =============Received accountable: #{accountable_object}  and #{bank}=============="
      begin
        stripe_bank_account = Stripe::Account.create_external_account(
          accountable_object.stripe_account_id,
          {
            external_account: {
              object: "bank_account",
              country: bank.country || "US",
              currency: "usd",
              account_holder_name: bank.recipient_name || "Test",
              account_holder_type: "individual",
              routing_number: "110000000", #"bank.routing_number"
              account_number: "000123456789" #"bank.account_number"
            }
          }
        )
        bank.update_columns(stripe_bank_account_id: stripe_bank_account.id, is_verified: true)
      rescue Stripe::StripeError => e
				Rails.logger.info " =============Stripe Error: #{e.message}=============="
      end
		end

		def fetch_balance_from_plaid
			begin
				@bank_account_plaid = BankAccount.find_by_id(params[:id]) if params[:id]
				unless @bank_account_plaid.present? && @bank_account_plaid.access_token.present?
				  return render json: { status: 404, success: false, data: nil, message: "Bank not found or invalid" }, status: :not_found
				end

				bank_account_details = HTTParty.post("#{ENV['PLAID_URL']}/accounts/balance/get", {
					headers: { 'Content-Type' => 'application/json' },
					body: {
						client_id: ENV["PLAID_CLIENT_ID"],
						secret: ENV["PLAID_SECRET"],
						access_token: @bank_account_plaid&.access_token.to_s,
						options: {
							account_ids: [@bank_account_plaid&.geteway_account_id.to_s]
						}
					}.to_json
				})
				bank_accounts = bank_account_details["accounts"][0]["balances"]
				@bank_account_plaid.update(available_balance: bank_accounts["available"].to_f, current_balance: bank_accounts["current"].to_f)
				render json: {status: 200, success: true, data: BankAccountSerializer.new(@bank_account_plaid.reload).serializable_hash[:data], message: "Successfuly fetch balance"}, status: :ok
			rescue StandardError => e
				render json: {status: 500, success: false, data: nil, message: e.message }
			end
		end

		def create_funding_account_unityfi(location_user, bank)
			begin
				unityfi_service = UnityfiService.new
    		unityfi_service.create_funding_account(location_user, bank)
			rescue StandardError => e
				Rails.logger.info " =============Unityfi Error: #{e.message}=============="
			end


			# begin
			# 	funding_params = params[:funding_account_data]
			# 	accountable_object = params[:bank_accountable_type].camelize.constantize.find_by(id: params[:bank_accountable_id].to_s)
			# 	return render json: {status: 422, success: false, data: nil, message: "#{params[:bank_accountable_type].camelize.constantize} not found"} unless accountable_object.present?

			# 	bank = accountable_object.reload.bank_accounts.new
			# 	bank.bank_account_type = funding_params[:AccountType].to_s.downcase
			# 	bank.account_number = funding_params[:BankAccount][:AccountLastFour]
			# 	bank.routing_number = funding_params[:BankAccount][:RoutingNumber]
			# 	bank.recipient_name = funding_params[:NameOnAccount]
			# 	bank.recipient_address = current_user&.address
			# 	bank.funding_account_id = funding_params[:FundingAccountId].to_i
			# 	bank.unityfi_bank_details_json = funding_params.to_json
			# 	bank.save
			# 	if accountable_object.class.name == "Association"
			# 		render json: {status: 200, success: true, data: AssociationsSerializer.new(accountable_object).serializable_hash[:data], message: "Successfuly Added"}, status: :ok
			# 	else
			# 		bank_accounts = current_user.bank_accounts
			# 		render json: {status: 200, success: true, data: BankAccountSerializer.new(bank_accounts).serializable_hash[:data], message: "Successfuly Added"}, status: :ok
			# 	end
			# rescue StandardError => e
			# 	render json: {status: 500, success: false, data: nil, message: e.message }
			# end
		end

		private
		def set_bank
			@bank_account = current_user.bank_accounts.find_by_id(params[:id]) if params[:id]
			return render json: {status: 404, success: false, data: nil, message: "Bank Account not found"}, :status => :not_found unless @bank_account.present?
		end

		def bank_account_params
			params.require(:bank_account).permit(:account_purpose, :name, :recipient_name, :recipient_address, :description, :bank_account_type, :country, :account_number, :routing_number, :is_active, :is_epay)
		end

		def render_unprocessable_entity_response(exception)
			render json: {status: 422, success: false, data: nil, message: exception.record.errors.full_messages.join(", ")}, :status => :unprocessable_entity
	    # return render json: { errors: {message: [exception.message]}}, status: :unprocessable_entity
	  end

		def friendly_stripe_error(e)
			case e.message
			when /routing number .* does not correspond/
				"Please enter a valid routing number."
			when /is required in test mode/
				"Please use a valid test account number in test mode."
			else
				e.message
			end
		end

	end
end