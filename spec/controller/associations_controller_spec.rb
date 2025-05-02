require 'rails_helper'
RSpec.describe V1::AssociationsController, type: :controller do
  before(:each) do
    @user = FactoryBot.create(:user)
    @association = FactoryBot.create(:association, property_manager_id: @user.id)
    @association2 = FactoryBot.create(:association, property_manager_id: @user.id)
    @association_address = FactoryBot.create(:association_address, association_id: @association2.id)
  end

  describe "GET #index" do
    it "returns a successful response with association list" do
      @community_association_manager = FactoryBot.create(:community_association_manager, association_id: @association2.id, user: @user)
      get :index, params: { user_id: @user.id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to have_key('data')
    end
  end

  describe "GET #show" do
    it "returns the association details" do
      get :show, params: { user_id: @user.id, id: @association.id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data']['id']).to eq(@association.id.to_s)
    end

    it "returns the association details with address" do
      get :show, params: { user_id: @user.id, id: @association2.id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data']['id']).to eq(@association2.id.to_s)
      expect(JSON.parse(response.body)["data"]["attributes"]["address"]["id"]).to eq(@association_address.id.to_s)
    end

    it 'returns not found if association does not exist' do
      get :show, params: { user_id: @user.id, id: 0 }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "Error handling" do
    it "returns 404 if user not found" do
      get :index, params: { user_id: 0 }
      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 if association not found" do
      get :show, params: { user_id: @user.id, id: 0 }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST #create" do
    it "Creates a new association" do
      post :create, params: valid_params
      expect(response).to have_http_status(:created)
    end

    it 'returns errors when params are invalid' do
      post :create, params: invalid_params
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to have_key('errors')
    end
  end

  describe "PUT #update" do
    it "updates the association" do
      put :update, params: {user_id: @user.id, id: @association.id, association: { name: "Updated Name" } }
      expect(response).to have_http_status(:ok)
      expect(@association.reload.name).to eq("Updated Name")
    end
  end

  describe "DELETE #destroy" do
    it "destroys the association" do
      delete :destroy, params: { user_id: @user.id, id: @association.id }
      expect(response).to have_http_status(:ok)
    end

    it "does not update and returns errors" do
      put :update, params: {user_id: @user.id, id: @association.id, association: {name: nil} }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['errors']).to be_present
    end

     it "returns a 404 error" do
      put :update, params: {user_id: @user.id, id: @association.id, association: { association_address_attributes: {id: 0} }
      }

      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)['errors']).to be_present
    end

    it "returns a 500 internal server error" do
      allow_any_instance_of(Association).to receive(:update).and_raise(StandardError, "Unexpected error")

      put :update, params: {user_id: @user.id, id: @association.id, association: { name: "Trigger Error" }
      }

      expect(response).to have_http_status(:internal_server_error)
      expect(JSON.parse(response.body)['errors']).to be_present
    end
  end

  private
  def valid_params
    { user_id: @user.id, association: { name: "Test", telephone_no: Faker::PhoneNumber.phone_number, email: Faker::Internet.email, is_active: true, community_association_managers_attributes: [{user_id: @user.id, created_by: @user.id}]} }
  end

  def invalid_params
    { user_id: @user.id, association: { name: "", telephone_no: Faker::PhoneNumber.phone_number, email: Faker::Internet.email, is_active: true} }
  end
end