module V1
	class BankAccountsController < ApplicationController
		before_action :set_bank, only: [:show, :destroy, :update]
		# rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity_response
		def index
			bank_accounts = current_user.bank_accounts.paginate(page: (params[:page] || 1), per_page: (params[:per_page] || 10))
			total_pages = bank_accounts.present? ? bank_accounts.total_pages : 0
			render json: {status: 200, success: true, data: BankAccountSerializer.new(bank_accounts).serializable_hash[:data], pagination_data: {total_pages: total_pages, total_records: bank_accounts.count}, message: "Bank Account list"}, status: :ok
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