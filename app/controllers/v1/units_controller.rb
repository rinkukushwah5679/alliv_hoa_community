module V1
	class UnitsController < ApplicationController
		# before_action :set_user
		before_action :set_association#, only: [:index, :show, :update, :destroy]
		def index
			units = @association.units.order("created_at DESC").paginate(page: (params[:page] || 1), per_page: (params[:per_page] || 10))
			total_pages = units.present? ? units.total_pages : 0
			render json: UnitSerializer.new(units, meta: {total_pages: total_pages, total_users: units.count, message: "Unit list"}).serializable_hash, status: :ok
		end






		def create
			
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

		def unit_params
			params.require(:unit).permit(:name, :unit_number, :state, :city, :zip_code, :street, :building_no, :floor, :unit_bedrooms, :unit_bathrooms, :surface_area, :notice_document, :description, :created_by, :updated_by
				ownership_account_attributes: [:id, :unit_owner_id, :first_name, :last_name, :phone_number, :email, :is_owner_association_board_member, :is_tenant_occupies_unit, :tenant_id, :tenant_first_name, :tenant_last_name, :tenant_phone_number, :tenant_email, :date_of_purchase, :inheritance_date],
				unit_financial_attributes: [:id, :amount, :frequency, :start_date],
				)
		end
	end
end