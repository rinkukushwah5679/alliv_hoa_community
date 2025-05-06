module V1
	class UsersController < ApplicationController

		#Unit owner 
		def property_owners
			users = User.property_owners.order("created_at DESC")
			render json: UserSerializer.new(users).serializable_hash, status: :ok
		end

	end
end