require 'rails_helper'
RSpec.describe V1::BankAccountsController, type: :controller do
  before(:each) do
    @user = FactoryBot.create(:user)
  end

  describe 'GET #index' do
    it 'returns a list of bank accounts' do
      get :index, params: { user_id: @user.id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to have_key('data')
    end
  end

  describe 'GET #show' do
    let(:bank_account) { FactoryBot.create(:bank_account, user_id: @user.id) }

    it 'returns a specific bank account' do
      get :show, params: { user_id: @user.id, id: bank_account.id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to have_key('data')
    end

    it 'returns not found if bank account does not exist' do
      get :show, params: { user_id: @user.id, id: 0 }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST #create' do
    let(:valid_params) do
      { bank_account: { name: 'Test Bank', description: 'Test Description', bank_account_type: 'Savings', country: 'USA', account_number: '123456789', routing_number: '987654321', is_active: true, created_by: @user.id, updated_by: @user.id } }
    end

    it 'creates a new bank account' do
      expect {
        post :create, params: valid_params.merge(user_id: @user.id)
      }.to change(BankAccount, :count).by(1)
      expect(response).to have_http_status(:created)
    end

    it 'returns errors when params are invalid' do
      post :create, params: {user_id: @user.id, bank_account: { name: '' } }.merge()
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to have_key('message')
    end
  end

  describe 'DELETE #destroy' do
    let!(:bank_account) { FactoryBot.create(:bank_account, user_id: @user.id, created_by: @user.id, updated_by: @user.id) }

    it 'deletes the bank account' do
      expect {
        delete :destroy, params: { user_id: @user.id, id: bank_account.id }
      }.to change(BankAccount, :count).by(-1)
      expect(response).to have_http_status(:ok)
    end

    it 'returns not found if bank account does not exist' do
      delete :destroy, params: { user_id: @user.id, id: 0 }
      expect(response).to have_http_status(:not_found)
    end
  end
end