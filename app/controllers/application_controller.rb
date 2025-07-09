class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  skip_before_action :verify_authenticity_token
  before_action :current_user
  before_action :store_current_user
  before_action :set_paper_trail_whodunnit

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = User.find_by(id: params[:user_id])
    return render json: {status: 404, success: false, data: nil, message: "Token has Expired, Please login again."}, :status => :not_found unless @current_user.present?
  end

  def store_current_user
    RequestStore.store[:current_user] = current_user
  end

  def set_paper_trail_whodunnit
    PaperTrail.request.whodunnit = current_user&.id.to_s
  end
end
