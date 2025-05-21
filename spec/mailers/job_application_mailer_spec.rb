require 'rails_helper'

RSpec.describe JobApplicationMailer, type: :mailer do
  describe '#new_application_notification' do
    let(:client) { create(:client, email: 'client@example.com') }
    let(:job_seeker) { create(:job_seeker, name: 'John Doe', email: 'jobseeker@example.com') }
    let(:opportunity) { create(:opportunity, title: 'Registered Nurse', client: client) }
    let(:application) { create(:job_application, opportunity: opportunity, job_seeker: job_seeker) }
    let(:mail) { described_class.new_application_notification(application) }

    it 'renders the headers' do
      expect(mail.subject).to eq('New application for Registered Nurse')
      expect(mail.to).to eq(['client@example.com'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to include('John Doe')
      expect(mail.body.encoded).to include('jobseeker@example.com')
      expect(mail.body.encoded).to include('Registered Nurse')
    end
  end
end
