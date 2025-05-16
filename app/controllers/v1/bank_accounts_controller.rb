module V1
	class BankAccountsController < ApplicationController
		before_action :set_bank, only: [:show, :destroy]#, :update

		def index
			bank_accounts = BankAccount.paginate(page: (params[:page] || 1), per_page: (params[:per_page] || 10))
			total_pages = bank_accounts.present? ? bank_accounts.total_pages : 0
			render json: BankAccountSerializer.new(bank_accounts, meta: {total_pages: total_pages, total_users: bank_accounts.count}).serializable_hash, status: :ok
		end

		def show
			render json: BankAccountSerializer.new(@bank_account, meta: {message: "Bank details"}).serializable_hash, status: :ok
		end

		def create
			bank_account = BankAccount.new(bank_account_params)
			if bank_account.save
				render json: BankAccountSerializer.new(bank_account, meta: { message: 'Bank Account created successfully' }), status: :created
			else
				render json: { errors: bank_account.errors.full_messages }, status: :unprocessable_entity
			end
		end

		# The update request is skipped as there is no update request on QuickBooks
		# def update

		# end

		def destroy
			@bank_account.destroy
	    render json: {message:"Bank Account successfully destroyed."}, status: :ok
		end

		private
		def set_bank
			@bank_account = BankAccount.find_by_id(params[:id]) if params[:id]
			return render json: {errors: {message: ["Bank Account not found"]}}, :status => :not_found unless @bank_account.present?
		end

		def bank_account_params
			params.require(:bank_account).permit(:name, :description, :bank_account_type, :country, :account_number, :routing_number, :is_active)
		end

	end
end