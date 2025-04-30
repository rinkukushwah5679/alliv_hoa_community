module V1
	class AssociationsController < ApplicationController
		before_action :set_user
		before_action :set_association, only: [:show, :update, :destroy]
		def index

		end

		def show
			render json: AssociationsSerializer.new(@association, meta: {message: "Association details"}).serializable_hash, status: :ok
		end

		def create
		  association = @user.associations.new(association_params)
		  if association.save
		    render json: AssociationsSerializer.new(association, meta: { message: "Association created successfully"}), status: :created
		  else
		    render json: { errors: association.errors.full_messages }, status: :unprocessable_entity
		  end
		end

		def update
		  if @association.update(association_params)
		    render json: { message: "Association updated successfully" }, status: :ok
		  else
		    render json: { errors: @association.errors.full_messages }, status: :unprocessable_entity
		  end
		end

		def destroy
			
		end


		private
		def association_params
			params.require(:association).permit(:name, :telephone_no, :email, :web_url, :created_by, :updated_by,
			association_address_attributes: [:id, :street, :building_no, :zip_code, :state, :city, :created_by, :updated_by, :_destroy],
	    association_due_attributes: [:id, :distribution_type, :amount, :frequency, :start_date, :created_by, :updated_by],
	    association_late_payment_fee_attributes: [:id, :amount, :frequency, :created_by, :updated_by],
	    tax_information_attributes: [:id, :tax_payer_type, :tax_payer_id], 
	    community_association_managers_attributes: [:id, :user_id, :created_by, :_destroy])
		end

		def set_user
			#Is current_user
			@user = User.find_by(id: params[:user_id])
			return render json: {errors: {message: ["User not found"]}}, :status => :not_found unless @user.present?
		end

		def set_association
			@association = @user.associations.find_by_id(params[:id]) if params[:id]
			return render json: {errors: {message: ["Association not found"]}}, :status => :not_found unless @association.present?
		end
	end
end