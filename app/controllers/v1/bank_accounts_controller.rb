module V1
	class BankAccountsController < ApplicationController
		before_action :set_bank, only: [:show, :destroy]#, :update

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
				bank_account = current_user.bank_accounts.new(bank_account_params)
				if bank_account.save
					render json: {status: 201, success: true, data: BankAccountSerializer.new(bank_account).serializable_hash[:data], message: "Bank Account created successfully"}, status: :created
				else
					render json: {status: 422, success: false, data: nil, message: bank_account.errors.full_messages.join(", ")}, :status => :unprocessable_entity
				end
			rescue StandardError => e
				render json: {status: 500, success: false, data: nil, message: e.message }, :status => :internal_server_error
			end
		end

		# The update request is skipped as there is no update request on QuickBooks
		# def update

		# end

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

	end
end