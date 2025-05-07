module V1
	class UnitsController < ApplicationController
		# before_action :set_user
		before_action :set_association#, only: [:index, :show, :update, :destroy]
		before_action :set_unit, only: [:show, :update, :destroy]
		def index
			units = @association.units.order("created_at DESC").paginate(page: (params[:page] || 1), per_page: (params[:per_page] || 10))
			total_pages = units.present? ? units.total_pages : 0
			render json: UnitDetailsSerializer.new(units, meta: {total_pages: total_pages, total_users: units.count, message: "Unit list"}).serializable_hash, status: :ok
		end

		def show
			render json: UnitDetailsSerializer.new(@unit, meta: {message: "Unit details"}).serializable_hash, status: :ok
		end

		def create
			unit = @association.units.new(unit_params)
			if unit.save
				render json: UnitDetailsSerializer.new(unit, meta: { message: "Unit created successfully"}), status: :created
			else
				render json: { errors: unit.errors.full_messages }, status: :unprocessable_entity
			end
		end

		def update
			begin
				if @unit.update(unit_params)
					render json: UnitDetailsSerializer.new(@unit, meta: { message: "Unit updated successfully"}), status: :ok
			  else
			    render json: { errors: @unit.errors.full_messages }, status: :unprocessable_entity
			  end
			rescue ActiveRecord::RecordNotFound => e
				render json: { errors: e.message }, status: :not_found
			rescue StandardError => e
				render json: {errors: e.message}, status: :internal_server_error
			end
		end

		def destroy
			@unit.destroy
	    render json: {message:"Unit successfully destroyed."}, status: :ok
		end

		private
		# def set_user
		# 	#Is current_user
		# 	@user = User.find_by(id: params[:user_id])
		# 	return render json: {errors: {message: ["User not found"]}}, :status => :not_found unless @user.present?
		# end


		def set_association
			@association = Association.find_by(id: params[:association_id]) if params[:association_id]
			return render json: {errors: {message: ["Association not found"]}}, :status => :not_found unless @association.present?
		end

		def set_unit
			@unit = @association.units.find_by(id: params[:id])
			return render json: {errors: {message: ["Unit not found"]}}, :status => :not_found unless @unit.present?
		end

		def unit_params
			params.require(:unit).permit(:name, :unit_number, :state, :city, :zip_code, :street, :building_no, :floor, :unit_bedrooms, :unit_bathrooms, :surface_area, :notice_document, :description, :created_by, :updated_by,
				ownership_account_attributes: [:id, :unit_owner_id, :first_name, :last_name, :phone_number, :email, :is_owner_association_board_member, :is_tenant_occupies_unit, :tenant_id, :tenant_first_name, :tenant_last_name, :tenant_phone_number, :tenant_email, :date_of_purchase, :inheritance_date, :created_by, :updated_by],
				unit_financial_attributes: [:id, :amount, :frequency, :start_date, :created_by, :updated_by],
				unit_file_attributes:[:id, :document, :_destroy])
		end
	end
end