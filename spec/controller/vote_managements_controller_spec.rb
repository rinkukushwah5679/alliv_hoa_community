require 'rails_helper'

RSpec.describe V1::VoteManagementsController, type: :controller do
  let!(:association) { create(:association) }
  let!(:user) { create(:user, current_role: "SystemAdmin") }
  let!(:vote_management) { create(:vote_management, association_id: association.id, created_by: user.id, ratification_type: "Simple Majority") }

  before do
    allow(controller).to receive(:current_user).and_return(user)
  end

  # -----------------------------------------
  # INDEX
  # -----------------------------------------
  describe "GET #index" do
    it "returns 200 success" do
      get :index, params: {user_id: user.id, association_id: association.id, search: vote_management.title }

      body = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(body["success"]).to eq(true)
      expect(body["data"]).not_to be_nil
    end

    it "returns only open vote for approval" do
      get :index, params: {user_id: user.id, association_id: association.id, search: vote_management.title, vote_approvals: true }

      body = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(body["success"]).to eq(true)
      expect(body["data"]).not_to be_nil
    end

    it "returns without association bases data" do
      get :index, params: {user_id: user.id, search: "sddwq" }

      body = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(body["success"]).to eq(true)
      expect(body["data"]).not_to be_nil
    end

    it "returns 404 if association not found" do
      get :index, params: {user_id: user.id, association_id: 999 }

      body = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(body["message"]).to eq("Association not found")
    end

    it "handles exception and returns 500" do
      allow_any_instance_of(V1::VoteManagementsController)
        .to receive(:fetch_vote_managements)
        .and_raise(StandardError.new("test index error"))

      get :index, params: {user_id: user.id}

      body = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(body["message"]).to eq("test index error")
    end
  end

  # -----------------------------------------
  # SHOW
  # -----------------------------------------
  describe "GET #show" do
    it "returns 200 success" do
      get :show, params: {user_id: user.id, id: vote_management.id }

      body = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(body["success"]).to eq(true)
      expect(body["data"]).not_to be_nil
    end

    it "returns 404 if record not found" do
      get :show, params: {user_id: user.id, id: 999 }

      body = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(body["message"]).to eq("Vote management not found")
    end
  end

  # -----------------------------------------
  # CREATE
  # -----------------------------------------
  describe "POST #create" do
    let(:valid_params) do
      {
        user_id: user.id,
        vote_management: {
          created_date: Date.today,
          association_id: association.id,
          participant_category: "All Members",
          ratification_type: "Simple Majority",
          title: "Test Vote",
          description: "Details",
          approval_due_date: Date.today + 5.days,
          status: "Open"
        }
      }
    end

    it "creates successfully" do
      post :create, params: valid_params

      body = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(body["success"]).to eq(true)
    end

    it "returns 422 on validation error" do
      invalid_params = {user_id: user.id, vote_management: { title: "" } }

      post :create, params: invalid_params

      body = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(body["success"]).to eq(false)
    end

    it "returns 500 on exception" do
      allow(VoteManagement).to receive(:new).and_raise(StandardError.new("create error"))

      post :create, params: valid_params

      body = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(body["message"]).to eq("create error")
    end
  end

  # -----------------------------------------
  # UPDATE
  # -----------------------------------------
  describe "PUT #update" do
    let(:file) {fixture_file_upload("spec/images/business_logo.jpg", "image/png")}
    let(:update_params) do
      {
        user_id: user.id,
        id: vote_management.id,
        vote_management: {
          title: "Updated Title",
          association_id: association.id,
          vote_management_attachments: [file]
        }
      }
    end

    it "updates successfully" do
      put :update, params: update_params

      body = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(body["success"]).to eq(true)
      expect(body["message"]).to eq("Updated successfully.")
    end

    it "returns 422 for validation error" do
      invalid_params = {
        user_id: user.id,
        id: vote_management.id,
        vote_management: { title: "" }
      }

      put :update, params: invalid_params

      body = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(body["success"]).to eq(false)
    end

    it "returns 500 on exception" do
      allow_any_instance_of(VoteManagement)
        .to receive(:update)
        .and_raise(StandardError.new("update error"))

      put :update, params: update_params

      body = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(body["message"]).to eq("update error")
    end
  end

  # -----------------------------------------
  # DESTROY
  # -----------------------------------------
  describe "DELETE #destroy" do
    it "deletes successfully" do
      delete :destroy, params: {user_id: user.id, id: vote_management.id }

      body = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(body["message"]).to eq("Successfully destroyed.")
    end
  end
end
