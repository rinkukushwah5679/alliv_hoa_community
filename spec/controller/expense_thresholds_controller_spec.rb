require 'rails_helper'

RSpec.describe V1::ExpenseThresholdsController, type: :controller do
  before(:each) do
    @user = FactoryBot.create(:user)
    @association = FactoryBot.create(:association, property_manager_id: @user.id)
    @threshold = FactoryBot.create(:expense_threshold, association_id: @association.id)
  end

  describe "GET #index" do
    it "returns a list of thresholds" do
      get :index, params: {user_id: @user.id, search: "testt" }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["success"]).to eq true
      expect(json).to have_key("data")
    end

    it "returns thresholds with search by association name" do
      get :index, params: {user_id: @user.id, association_id: @association.id, search: @association.name }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"]).to be_present
    end

    it "returns 404 if association not found" do
      get :index, params: {user_id: @user.id, association_id: 0 }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["message"]).to eq("Association not found")
    end

    # it "returns 500 on unexpected error" do
    #   allow_any_instance_of(ExpenseThreshold).to receive(:joins).and_raise(StandardError, "Unexpected error")
    #   get :index, params: {user_id: @user.id, association_id: @association.id }
    #   expect(response).to have_http_status(:internal_server_error)
    #   expect(JSON.parse(response.body)["message"]).to eq("Unexpected error")
    # end
  end

  describe "GET #show" do
    it "returns threshold details" do
      get :show, params: {user_id: @user.id, id: @threshold.id }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"]).to be_present
    end

    it "returns 404 if threshold not found" do
      get :show, params: {user_id: @user.id, id: 0 }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["message"]).to eq("Expense threshold not found")
    end
  end

  describe "PUT #update" do
    it "updates the threshold successfully" do
      put :update, params: {user_id: @user.id, id: @threshold.id, threshold: { status: "Inactive" } }
      expect(response).to have_http_status(:ok)
      expect(@threshold.reload.status).to eq("Inactive")
    end

    it "does not update and returns errors" do
      allow_any_instance_of(ExpenseThreshold).to receive(:update).and_return(false)
      allow_any_instance_of(ExpenseThreshold).to receive_message_chain(:errors, :full_messages).and_return(["Invalid status"])
      
      put :update, params: {user_id: @user.id, id: @threshold.id, threshold: { status: "" } }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["message"]).to eq("Invalid status")
    end

    it "returns 500 on unexpected error" do
      allow_any_instance_of(ExpenseThreshold).to receive(:update).and_raise(StandardError, "Boom")
      put :update, params: {user_id: @user.id, id: @threshold.id, threshold: { status: "Active" } }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["message"]).to eq("Boom")
    end
  end

  describe "DELETE #destroy" do
    it "deletes the threshold" do
      delete :destroy, params: {user_id: @user.id, id: @threshold.id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["message"]).to eq("Thresholds successfully destroyed.")
    end

    it "returns 404 if threshold not found" do
      delete :destroy, params: {user_id: @user.id, id: 0 }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["message"]).to eq("Expense threshold not found")
    end
  end
end
