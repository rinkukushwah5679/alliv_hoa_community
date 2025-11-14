require 'rails_helper'

RSpec.describe V1::AmenitiesController, type: :controller do
  before(:each) do
    @user = FactoryBot.create(:user, current_role: "SystemAdmin")
    @association = FactoryBot.create(:association, property_manager_id: @user.id)
    @amenity = FactoryBot.create(:amenity, association_id: @association.id)

    # allow(controller).to receive(:current_user).and_return(@user)
  end

  describe "GET #index" do
    context "when association_id is present" do
      it "returns list of amenities for given association" do
        get :index, params: {user_id: @user.id, association_id: @association.id }
        json = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(json["success"]).to eq(true)
        expect(json["data"]).to be_an(Array)
      end
    end

    context "when association_id is invalid" do
      it "returns 404 association not found" do
        get :index, params: {user_id: @user.id, association_id: "wrong-id" }
        json = JSON.parse(response.body)

        expect(json["status"]).to eq(404)
        expect(json["message"]).to eq("Association not found")
      end
    end

    context "without association_id" do
      it "returns amenities based on user's associations" do
        get :index, params: {user_id: @user.id}
        json = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(json["success"]).to eq(true)
        expect(json["data"]).to be_an(Array)
      end
    end

    context "with search param" do
      it "filters amenities by name" do
        get :index, params: {user_id: @user.id, search: @amenity.amenity_name[0..3] }
        json = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(json["data"].first["attributes"]["amenity_name"]).to eq(@amenity.amenity_name)
      end
    end
  end

  describe "GET #show" do
    context "when amenity exists" do
      it "returns amenity details" do
        get :show, params: {user_id: @user.id, id: @amenity.id }
        json = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(json["data"]["attributes"]["amenity_name"]).to eq(@amenity.amenity_name)
      end
    end

    context "when amenity not found" do
      it "returns 404 not found" do
        get :show, params: {user_id: @user.id, id: "wrong-id" }
        json = JSON.parse(response.body)

        expect(json["status"]).to eq(404)
        expect(json["message"]).to eq("Amenity not found")
      end
    end
  end

  describe "POST #create" do
    let(:valid_params) do
      {
        user_id: @user.id,
        amenity: {
          association_id: @association.id,
          amenity_name: "Gym",
          description: "Full AC Gym",
          serial_number_sku: "GYM-101",
          location: "Block A",
          participants: "All Members"
        }
      }
    end

    it "creates amenity successfully" do
      post :create, params: valid_params
      json = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(json["success"]).to eq(true)
      expect(json["message"]).to eq("Updated successfully.")
    end

    it "returns 422 if validation fails" do
      invalid_params = valid_params
      invalid_params[:amenity][:association_id] = nil

      post :create, params: invalid_params
      json = JSON.parse(response.body)

      expect(json["status"]).to eq(422)
      expect(json["message"]).to be_present
    end

    it "returns 500 on unexpected error" do
      allow_any_instance_of(Amenity).to receive(:save).and_raise(StandardError, "Unexpected")

      post :create, params: valid_params
      json = JSON.parse(response.body)

      expect(json["status"]).to eq(500)
      expect(json["message"]).to eq("Unexpected")
    end
  end

  describe "PUT #update" do
    it "updates amenity successfully" do
      put :update, params: {user_id: @user.id, id: @amenity.id, amenity: { amenity_name: "Updated Gym" } }
      json = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(json["data"]["attributes"]["amenity_name"]).to eq("Updated Gym")
    end

    it "returns 422 if validation fails" do
      put :update, params: {user_id: @user.id, id: @amenity.id, amenity: { association_id: nil } }
      json = JSON.parse(response.body)

      expect(json["status"]).to eq(422)
      expect(json["message"]).to be_present
    end

    it "attaches new files if provided" do
      file = fixture_file_upload("spec/images/business_logo.jpg", "image/png")

      put :update, params: {
        user_id: @user.id,
        id: @amenity.id,
        amenity: { amenity_name: "Gym 2", amenity_attachments: [file] }
      }

      expect(@amenity.reload.amenity_attachments.count).to eq(1)
    end

    it "returns 500 on error" do
      allow_any_instance_of(Amenity).to receive(:update).and_raise(StandardError, "Update Failed")

      put :update, params: {user_id: @user.id, id: @amenity.id, amenity: { amenity_name: "X" } }
      json = JSON.parse(response.body)

      expect(json["status"]).to eq(500)
      expect(json["message"]).to eq("Update Failed")
    end
  end

  describe "DELETE #destroy" do
    it "deletes the amenity" do
      expect {
        delete :destroy, params: {user_id: @user.id, id: @amenity.id }
      }.to change(Amenity, :count).by(-1)

      json = JSON.parse(response.body)
      expect(json["message"]).to eq("Amenity successfully destroyed.")
    end
  end
end
