require 'rails_helper'

RSpec.describe Api::JobSeekerSessionsController, type: :controller do
  describe 'POST #create' do
    let(:job_seeker) { create(:job_seeker, email: 'jobseeker@example.com', password: 'password123') }

    context 'with valid credentials' do
      it 'returns a JWT token' do
        post :create, params: { email: job_seeker.email, password: 'password123' }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include('token')
      end
    end

    context 'with invalid credentials' do
      it 'returns unauthorized status' do
        post :create, params: { email: job_seeker.email, password: 'wrong_password' }
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to include('error')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'returns a success message' do
      delete :destroy
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to include('message' => 'Logged out successfully')
    end
  end
end
