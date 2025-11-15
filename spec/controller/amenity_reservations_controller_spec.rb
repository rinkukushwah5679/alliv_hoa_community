require "rails_helper"

RSpec.describe V1::AmenityReservationsController, type: :controller do
  before(:each) do
    @user = FactoryBot.create(:user, current_role: "Resident")
    @user.add_role(:Resident)
    @association = FactoryBot.create(:association)
    @amenity = FactoryBot.create(:amenity, association_id: @association.id)

    @reservation = FactoryBot.create(
      :amenity_reservation,
      user_id: @user.id,
      association_id: @association.id,
      amenity_id: @amenity.id
    )
  end

  # ---------------------------------------------
  # INDEX
  # ---------------------------------------------
  describe "GET #index" do
    it "returns reservation list" do
      get :index, params: {user_id: @user.id, association_id: @association.id, search: @association.name }

      json = JSON.parse(response.body)
      expect(json["status"]).to eq(200)
      expect(json["success"]).to eq(true)
      expect(json["data"]).not_to be_empty
    end

    it "returns 404 when association not found" do
      get :index, params: {user_id: @user.id, association_id: "invalid-id" }

      json = JSON.parse(response.body)
      expect(json["status"]).to eq(404)
      expect(json["message"]).to eq("Association not found")
    end

    it "returns amenity reservation based on user's associations search with amenity name" do
      get :index, params: {user_id: @user.id, search: @amenity.amenity_name}
      json = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(json["success"]).to eq(true)
      expect(json["data"]).to be_an(Array)
    end
  end

  # ---------------------------------------------
  # SHOW
  # ---------------------------------------------
  describe "GET #show" do
    it "returns reservation details" do
      get :show, params: {user_id: @user.id, id: @reservation.id }
      json = JSON.parse(response.body)

      expect(json["status"]).to eq(200)
      expect(json["success"]).to eq(true)
      expect(json["data"]).not_to be_nil
    end

    it "returns 404 when reservation not found" do
      get :show, params: {user_id: @user.id, id: "unknown" }
      json = JSON.parse(response.body)

      expect(json["status"]).to eq(404)
      expect(json["message"]).to eq("Amenity reservation not found")
    end
  end

  # ---------------------------------------------
  # CREATE
  # ---------------------------------------------
  describe "POST #create" do
    let(:valid_params) do
      {
        user_id: @user.id,
        amenity_reservation: {
          association_id: @association.id,
          amenity_id: @amenity.id,
          description: "Test reservation",
          reservation_date: Date.today,
          start_time: "10:00",
          end_time: "11:00"
        }
      }
    end

    it "creates a reservation" do
      post :create, params: valid_params
      json = JSON.parse(response.body)

      expect(json["status"]).to eq(200)
      expect(json["success"]).to eq(true)
    end

    it "returns 422 if validation fails" do
      invalid_params = {
        user_id: @user.id,
        amenity_reservation: { association_id: nil }
      }

      post :create, params: invalid_params
      json = JSON.parse(response.body)

      expect(json["status"]).to eq(422)
      expect(json["success"]).to eq(false)
    end

    it "returns 500 on unexpected error" do
      allow_any_instance_of(User)
        .to receive(:amenity_reservations)
        .and_raise(StandardError.new("Create crash"))

      post :create, params: valid_params
      json = JSON.parse(response.body)

      expect(json["status"]).to eq(500)
      expect(json["message"]).to eq("Create crash")
    end
  end

  # ---------------------------------------------
  # UPDATE
  # ---------------------------------------------
  describe "PUT #update" do
    it "updates reservation" do
      put :update, params: {
        user_id: @user.id,
        id: @reservation.id,
        amenity_reservation: {
          reservation_date: Date.today + 1.day,
          start_time: "12:00",
          end_time: "13:00"
        }
      }

      json = JSON.parse(response.body)
      expect(json["status"]).to eq(200)
      expect(json["success"]).to eq(true)
    end

    it "returns 422 on invalid update" do
      put :update, params: {
        user_id: @user.id,
        id: @reservation.id,
        amenity_reservation: { reservation_date: nil }
      }

      json = JSON.parse(response.body)
      expect(json["status"]).to eq(422)
      expect(json["success"]).to eq(false)
    end

    it "returns 500 on unexpected error" do
      allow_any_instance_of(AmenityReservation)
        .to receive(:update)
        .and_raise(StandardError.new("Update crash"))

      put :update, params: {
        user_id: @user.id,
        id: @reservation.id,
        amenity_reservation: { reservation_date: Date.today }
      }

      json = JSON.parse(response.body)
      expect(json["status"]).to eq(500)
      expect(json["message"]).to eq("Update crash")
    end
  end

  # ---------------------------------------------
  # DESTROY
  # ---------------------------------------------
  describe "DELETE #destroy" do
    it "destroys the reservation" do
      delete :destroy, params: {user_id: @user.id, id: @reservation.id }
      json = JSON.parse(response.body)

      expect(json["status"]).to eq(200)
      expect(json["message"]).to eq("Reservation successfully destroyed.")
    end
  end
end
