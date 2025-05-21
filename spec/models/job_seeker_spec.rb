require 'rails_helper'

RSpec.describe JobSeeker, type: :model do
  describe 'associations' do
    it { should have_many(:job_applications) }
    it { should have_many(:opportunities).through(:job_applications) }
  end

  describe 'validations' do
    subject { build(:job_seeker) }

    it { should validate_presence_of(:email) }
    it { should validate_length_of(:password).is_at_least(6) }
    it { should allow_value('user@example.com').for(:email) }
    it { should_not allow_value('invalid_email').for(:email) }

    it 'validates case-insensitive uniqueness of email' do
      job_seeker = create(:job_seeker, email: 'test@example.com')
      new_job_seeker = build(:job_seeker, email: 'TEST@example.com')
      expect(new_job_seeker).not_to be_valid
      expect(new_job_seeker.errors[:email]).to include('has already been taken')
    end
  end

  describe 'authentication' do
    let(:job_seeker) { create(:job_seeker, password: 'password123') }

    it 'authenticates with correct password' do
      expect(job_seeker.authenticate('password123')).to be_truthy
    end

    it 'does not authenticate with incorrect password' do
      expect(job_seeker.authenticate('wrong_password')).to be_falsey
    end
  end

  describe 'jwt_subject' do
    it 'returns the job seeker id' do
      job_seeker = create(:job_seeker)
      expect(job_seeker.jwt_subject).to eq(job_seeker.id)
    end
  end
end
