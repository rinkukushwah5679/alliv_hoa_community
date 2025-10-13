require 'rails_helper'

RSpec.describe V1::MeetingEventsController, type: :controller do
  before(:each) do
    @user = FactoryBot.create(:user)
    @association = FactoryBot.create(:association, property_manager_id: @user.id)
    @meeting_event = FactoryBot.create(:meeting_event, association_id: @association.id, title: "Board Event")
  end

  describe "GET #index" do
    context "when association_id is present" do
      it "returns list of meeting events for given association" do
        get :index, params: {user_id: @user.id, association_id: @association.id }
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["success"]).to eq(true)
        expect(json["data"]).to be_an(Array)
      end
    end

    context "when association_id is invalid" do
      it "returns 404 association not found" do
        get :index, params: {user_id: @user.id, association_id: "invalid-id" }
        json = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(json["message"]).to eq("Association not found")
      end
    end

    context "when no association_id (fetch from current_user)" do
      it "returns all events from user’s associations" do
        allow(@user).to receive(:associations).and_return([@association])
        get :index, params: {user_id: @user.id}
        json = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(json["data"]).to be_an(Array)
      end
    end

    context "when search term is provided" do
      it "filters meeting by title" do
        get :index, params: {user_id: @user.id, search: "Board" }
        json = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(json["data"].first["attributes"]["title"]).to eq("Board Event")
      end
    end
  end

  describe "GET #show" do
    context "when event exists" do
      it "returns event details" do
        get :show, params: {user_id: @user.id, id: @meeting_event.id }
        json = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(json["data"]["attributes"]["title"]).to eq("Board Event")
      end
    end

    context "when event not found" do
      it "returns 404 not found" do
        get :show, params: {user_id: @user.id, id: "invalid-id" }
        json = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(json["message"]).to eq("Event not found")
      end
    end
  end

  describe "POST #create" do
    let(:valid_params) do
      { user_id: @user.id,
        events: {
          association_id: @association.id,
          title: "New Meeting",
          description: "Discuss new policies",
          meeting_type: "Board Meeting",
          user_id: @user.id,
          unit_number: "10",
          meeting_date: Time.now.to_date + 1.day,
          start_time: "13:00",
          end_time: "14:00",
          location: "In-Person",
          address: "Noida",
          participants: "All Members"
        }
      }
    end

    it "creates a new meeting event successfully" do
      post :create, params: valid_params
      json = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(json["message"]).to eq("Updated successfully.")
    end

    it "returns 422 if validation fails" do
      invalid_params = valid_params
      invalid_params[:events][:association_id] = nil
      post :create, params: invalid_params
      json = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(json["message"]).to include("Custom association must exist")
    end
  end

  describe "PUT #update" do
    it "updates event successfully" do
      put :update, params: {user_id: @user.id, id: @meeting_event.id, events: { title: "Updated Event" } }
      json = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(json["data"]["attributes"]["title"]).to eq("Updated Event")
    end

    it "returns 422 if validation fails meeting date in past" do
      put :update, params: {user_id: @user.id, id: @meeting_event.id, events: { title: "Updated Event", meeting_date: 1.day.ago.to_date } }
      json = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(json["message"]).to eq("Meeting date can't be in the past")
    end

    it "returns 404 when event not found" do
      put :update, params: {user_id: @user.id, id: "invalid-id", events: { title: "Updated Event" } }
      json = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(json["message"]).to eq("Event not found")
    end

    it "returns a 500 internal server error" do
      allow_any_instance_of(MeetingEvent).to receive(:update).and_raise(StandardError, "Unexpected error")

      put :update, params: {user_id: @user.id, id: @meeting_event.id, events: { title: "Trigger Error" }}
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['message']).to be_present
    end
  end

  describe "DELETE #destroy" do
    it "deletes the event successfully" do
      expect {
        delete :destroy, params: {user_id: @user.id, id: @meeting_event.id }
      }.to change(MeetingEvent, :count).by(-1)
      json = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(json["message"]).to eq("Event successfully destroyed.")
    end
  end
end
