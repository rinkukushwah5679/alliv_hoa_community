module V1
	class AssociationsController < ApplicationController
		# before_action :set_user
		before_action :set_association, only: [:show, :update, :destroy]
		def index
			associations = current_user.associations.order("created_at DESC").paginate(page: (params[:page] || 1), per_page: (params[:per_page] || 10))
			total_pages = associations.present? ? associations.total_pages : 0
			# render json: AssociationsListSerializer.new(associations, meta: {total_pages: total_pages, total_associations: associations.count, message: "Association list"}).serializable_hash, status: :ok
			render json: {status: 200, success: true, data: AssociationsListSerializer.new(associations).serializable_hash[:data], pagination_data: {total_pages: total_pages, total_records: associations.count}, message: "Association list"}, status: :ok
		end

		def show
			# render json: AssociationsSerializer.new(@association, meta: {message: "Association details"}).serializable_hash, status: :ok
			render json: {status: 200, success: true, data: AssociationsSerializer.new(@association).serializable_hash[:data], message: "Association details"}, status: :ok
		end

		def create
			begin
			  association = current_user.associations.new(association_params)
			  if association.save
			    render json: {status: 201, success: true, data: AssociationsSerializer.new(association).serializable_hash[:data], message: "Association created successfully"}, status: :created
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
					# render json: AssociationsSerializer.new(@association, meta: { message: "Association updated successfully"}), status: :ok
					render json: {status: 200, success: true, data: AssociationsSerializer.new(@association).serializable_hash[:data], message: "Association updated successfully"}, status: :ok
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


		private
		def association_params
			params.require(:association).permit(:name, :telephone_no, :email, :web_url, :is_active,
			association_address_attributes: [:id, :street, :building_no, :zip_code, :state, :city, :_destroy],
			bank_accounts_attributes: [:id, :account_purpose, :name, :description, :bank_account_type, :account_number, :routing_number, :is_active, :_destroy],
	    association_due_attributes: [:id, :distribution_type, :amount, :frequency, :start_date],
	    association_late_payment_fee_attributes: [:id, :amount, :frequency],
	    tax_information_attributes: [:id, :tax_payer_type, :tax_payer_id],
	    community_association_managers_attributes: [:id, :user_id, :_destroy],
	    units_attributes: [:id, :name, :unit_number, :state, :city, :zip_code, :street, :building_no, :floor, :unit_bedrooms, :unit_bathrooms, :surface_area, :_destroy])
		end

		def set_user
			#Is current_user
			@user = User.find_by(id: params[:user_id])
			return render json: {errors: "User not found"}, :status => :not_found unless @user.present?
		end

		def set_association
			@association = current_user.associations.find_by_id(params[:id]) if params[:id]
			# return render json: {errors: {message: ["Association not found"]}}, :status => :not_found unless @association.present?
			return render json: {status: 404, success: false, data: nil, message: "Association not found"}, :status => :not_found unless @association.present?
			# return render json: {errors: "Association not found"}, :status => :not_found unless @association.present?
		end
	end
end