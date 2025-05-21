require 'rails_helper'

RSpec.describe Client, type: :model do
  describe 'associations' do
    it { should have_many(:opportunities) }
  end

  describe 'validations' do
    subject { build(:client) }

    it { should validate_presence_of(:email) }
    it { should validate_length_of(:password).is_at_least(6) }
    it { should allow_value('user@example.com').for(:email) }
    it { should_not allow_value('invalid_email').for(:email) }

    it 'validates case-insensitive uniqueness of email' do
      client = create(:client, email: 'test@example.com')
      new_client = build(:client, email: 'TEST@example.com')
      expect(new_client).not_to be_valid
      expect(new_client.errors[:email]).to include('has already been taken')
    end
  end

  describe 'authentication' do
    let(:client) { create(:client, password: 'password123') }

    it 'authenticates with correct password' do
      expect(client.authenticate('password123')).to be_truthy
    end

    it 'does not authenticate with incorrect password' do
      expect(client.authenticate('wrong_password')).to be_falsey
    end
  end

  describe 'jwt_subject' do
    it 'returns the client id' do
      client = create(:client)
      expect(client.jwt_subject).to eq(client.id)
    end
  end
end
