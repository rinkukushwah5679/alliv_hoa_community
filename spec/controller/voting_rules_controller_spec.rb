require 'rails_helper'

RSpec.describe V1::VotingRulesController, type: :controller do
  before(:each) do
    @user = FactoryBot.create(:user)
    @association = FactoryBot.create(:association, property_manager_id: @user.id)
    @voting_rule = FactoryBot.create(:voting_rule, association_id: @association.id)
  end

  describe "GET #index" do
    it "returns a list of voting_rule" do
      get :index, params: {user_id: @user.id, search: "testt" }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["success"]).to eq true
      expect(json).to have_key("data")
    end

    it "returns voting_rule with search by association name" do
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
  end

  describe "GET #show" do
    it "returns voting_rule details" do
      get :show, params: {user_id: @user.id, id: @voting_rule.id }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"]).to be_present
    end

    it "returns 404 if voting_rule not found" do
      get :show, params: {user_id: @user.id, id: 0 }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["message"]).to eq("Voting rule not found")
    end
  end

  describe "PUT #update" do
    it "updates the voting_rule successfully" do
      put :update, params: {user_id: @user.id, id: @voting_rule.id, voting_rule: { status: "Inactive" } }
      expect(response).to have_http_status(:ok)
      expect(@voting_rule.reload.status).to eq("Inactive")
    end

    it "does not update and returns errors" do
      allow_any_instance_of(VotingRule).to receive(:update).and_return(false)
      allow_any_instance_of(VotingRule).to receive_message_chain(:errors, :full_messages).and_return(["Invalid status"])
      
      put :update, params: {user_id: @user.id, id: @voting_rule.id, voting_rule: { status: "" } }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["message"]).to eq("Invalid status")
    end

    it "returns 500 on unexpected error" do
      allow_any_instance_of(VotingRule).to receive(:update).and_raise(StandardError, "Boom")
      put :update, params: {user_id: @user.id, id: @voting_rule.id, voting_rule: { status: "Active" } }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["message"]).to eq("Boom")
    end
  end

  describe "DELETE #destroy" do
    it "deletes the voting_rule" do
      delete :destroy, params: {user_id: @user.id, id: @voting_rule.id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["message"]).to eq("Successfully destroyed.")
    end

    it "returns 404 if voting_rule not found" do
      delete :destroy, params: {user_id: @user.id, id: 0 }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["message"]).to eq("Voting rule not found")
    end
  end
end
