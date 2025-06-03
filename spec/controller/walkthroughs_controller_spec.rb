require 'rails_helper'
RSpec.describe V1::WalkthroughsController, type: :controller do
  before(:each) do
    @user = FactoryBot.create(:user)
    @association = FactoryBot.create(:association, property_manager_id: @user.id)
    @walkthrough = FactoryBot.create(:walkthrough, association_id: @association.id, user_id: @user.id)
  end
  describe "GET /v1/users/:user_id/associations/:association_id/walkthroughs" do
    it "returns a list of walkthroughs" do
      get :index, params: {user_id: @user.id, association_id: @association.id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to have_key('data')
    end
  end

  describe "GET /v1/users/:user_id/associations/:association_id/walkthroughs/:id" do
    it "returns details of walkthrough" do
      get :show, params: { user_id: @user.id, association_id: @association.id, id: @walkthrough.id}
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["data"]["id"]).to eq(@walkthrough.id.to_s)
    end
  end

  describe "Error handling" do
    it "returns 404 if walkthrough not found" do
      get :show, params: { user_id: @user.id, association_id: @association.id, id: 0 }
      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 if association not found for all action" do
      get :index, params: { user_id: @user.id, association_id: 0 }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /v1/users/:user_id/associations/:association_id/walkthroughs" do
    it "creates a walkthrough" do
      post :create, params: valid_params
      expect(response).to have_http_status(:created)
    end

    it 'returns errors when params are invalid' do
      post :create, params: invalid_params
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to have_key('message')
    end

    it "returns a 500 internal server error" do
      post :create, params: {user_id: @user.id, association_id: @association.id}
      expect(response).to have_http_status(:internal_server_error)
      expect(JSON.parse(response.body)['message']).to be_present
    end
  end

  describe "PUT #update" do
    it "updates the walkthrough" do
      put :update, params: {user_id: @user.id, association_id: @association.id, id: @walkthrough.id, walkthrough: { facade: "facade" } }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data']).to be_present
    end

    it "does not update and returns errors" do
      put :update, params: {user_id: @user.id, association_id: @association.id, id: @walkthrough.id, walkthrough: {facade: "Test", user_id: 0} }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['message']).to be_present
    end

    it "returns a 500 internal server error" do
      allow_any_instance_of(Walkthrough).to receive(:update).and_raise(StandardError, "Unexpected error")

      put :update, params: {user_id: @user.id, association_id: @association.id, id: @walkthrough.id, walkthrough: { facade: "Trigger Error" }}
      expect(response).to have_http_status(:internal_server_error)
      expect(JSON.parse(response.body)['message']).to be_present
    end
  end

  describe "DELETE #destroy" do
    it "deletes the walkthrough" do
      delete :destroy, params: { user_id: @user.id, association_id: @association.id, id: @walkthrough.id }
      expect(response).to have_http_status(:ok)
    end
  end

  private
  def valid_params
    { user_id: @user.id, association_id: @association.id, walkthrough: { user_id: @user.id, association_id: @association.id } }
  end

  def invalid_params
    { user_id: @user.id, association_id: @association.id, walkthrough: { user_id: 0, association_id: 0 } }
  end
end