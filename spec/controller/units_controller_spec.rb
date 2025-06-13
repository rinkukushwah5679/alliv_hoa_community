require 'rails_helper'
RSpec.describe V1::UnitsController, type: :controller do
  before(:each) do
    @user = FactoryBot.create(:user)
    @association = FactoryBot.create(:association, property_manager_id: @user.id)
    @unit = FactoryBot.create(:unit, association_id: @association.id)
  end
  describe "GET /v1/users/:user_id/units" do
    it "returns a list of units" do
      get :index, params: {user_id: @user.id, association_id: @association.id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to have_key('data')
    end
  end

  describe "GET /v1/users/:user_id/units/:id" do
    it "returns unit details" do
      get :show, params: { user_id: @user.id, association_id: @association.id, id: @unit.id}
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["data"]["id"]).to eq(@unit.id.to_s)
    end

    it "returns unit not found" do
      @user.add_role(:Resident)
      get :show, params: { user_id: @user.id, association_id: @association.id, id: @unit.id}
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)["message"]).to eq("Unit not found")
    end

    it "returns unit not found without association" do
      @user.add_role(:Resident)
      get :show, params: { user_id: @user.id, id: @unit.id}
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)["message"]).to eq("Unit not found")
    end
  end

  describe "Error handling" do
    it "returns 404 if unit not found" do
      get :show, params: { user_id: @user.id, association_id: @association.id, id: 0 }
      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 if association not found for all action" do
      get :index, params: { user_id: @user.id, association_id: 0 }
      expect(response).to have_http_status(:not_found)
    end
  end

  # describe "POST /v1/users/:user_id/associations/:association_id/units" do
  #   it "creates a unit" do
  #     post :create, params: valid_params
  #     expect(response).to have_http_status(:created)
  #   end

  #   it 'returns errors when params are invalid' do
  #     post :create, params: invalid_params
  #     expect(response).to have_http_status(:unprocessable_entity)
  #     expect(JSON.parse(response.body)).to have_key('errors')
  #   end
  # end

   describe "PUT #update" do
    it "updates the unit" do
      put :update, params: {user_id: @user.id, association_id: @association.id, id: @unit.id, unit: { name: "Updated Name" } }
      expect(response).to have_http_status(:ok)
      expect(@unit.reload.name).to eq("Updated Name")
    end

    it "does not update and returns errors" do
      put :update, params: {user_id: @user.id, association_id: @association.id, id: @unit.id, unit: {name: @unit.name, ownership_account_attributes: {first_name: ""}} }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["success"]).to eq false
      expect(JSON.parse(response.body)).to have_key('message')
    end

     it "returns a 404 error and ownership not found" do
      put :update, params: {user_id: @user.id, association_id: @association.id, id: @unit.id, unit: { ownership_account_attributes: {id: 0} }
      }

      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)["success"]).to eq false
      expect(JSON.parse(response.body)).to have_key('message')
    end

    it "returns a 500 internal server error" do
      allow_any_instance_of(Unit).to receive(:update).and_raise(StandardError, "Unexpected error")

      put :update, params: {user_id: @user.id, association_id: @association.id, id: @unit.id, unit: { name: "Trigger Error" }
      }

      expect(response).to have_http_status(:internal_server_error)
      expect(JSON.parse(response.body)["success"]).to eq false
      expect(JSON.parse(response.body)["message"]).to eq('Unexpected error')
    end
  end

  describe "DELETE #destroy" do
    it "deletes the unit" do
      delete :destroy, params: { user_id: @user.id, association_id: @association.id, id: @unit.id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /v1/users/:user_id/units/:id/unit_history" do
    it "returns unit history" do
      @unit.update(created_by: @user.id)
      get :unit_history, params: { user_id: @user.id, id: @unit.id}
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["data"]).to be_present
    end
  end

  private
  def valid_params
    { user_id: @user.id, association_id: @association.id, unit: { name: "Test Unit", unit_number: "101", state: "State", city: "City", zip_code: "12345", street: "Street", building_no: "B1", floor: "1", unit_bedrooms: 2, unit_bathrooms: 1, surface_area: 1200, created_by: @user.id, updated_by: @user.id, notice_document: Rack::Test::UploadedFile.new(Rails.root.join('spec/images/business_logo.jpg'), 'image/jpeg'), unit_file_attributes: {document: Rack::Test::UploadedFile.new(Rails.root.join('spec/images/business_logo.jpg'), 'image/jpeg'), created_by: @user.id, updated_by: @user.id}   } }
  end

  def invalid_params
    { user_id: @user.id, association_id: @association.id, unit: { name: "Test Unit", unit_number: "101", state: "State", city: "City", zip_code: "12345", street: "Street", building_no: "B1", floor: "1", unit_bedrooms: 2, unit_bathrooms: 1, surface_area: 1200, created_by: @user.id, updated_by: @user.id, ownership_account_attributes: {unit_owner_id: @user.id, first_name: ""}} }
  end

end