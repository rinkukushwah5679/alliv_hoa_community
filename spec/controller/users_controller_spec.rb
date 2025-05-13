require 'rails_helper'
RSpec.describe V1::UsersController, type: :controller do
  before(:each) do
    @user = FactoryBot.create(:user)
    @user.add_role(:PropertyOwner)
  end

  describe 'GET #property_owners' do
    it 'returns a list of  property owners' do
      get :property_owners, params: { user_id: @user.id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to have_key('data')
    end
  end
  
end