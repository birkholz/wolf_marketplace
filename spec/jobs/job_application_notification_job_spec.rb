require 'rails_helper'

RSpec.describe JobApplicationNotificationJob, type: :job do
  let(:client) { create(:client, email: 'client@example.com') }
  let(:job_seeker) { create(:job_seeker, name: 'John Doe', email: 'jobseeker@example.com') }
  let(:opportunity) { create(:opportunity, title: 'Registered Nurse', client: client) }
  let(:application) { create(:job_application, opportunity: opportunity, job_seeker: job_seeker) }

  it 'performs the job and sends the notification email' do
    expect {
      described_class.perform_now(application.id)
    }.to change { ActionMailer::Base.deliveries.count }.by(1)

    mail = ActionMailer::Base.deliveries.last
    expect(mail.to).to include(client.email)
    expect(mail.subject).to eq("New application for #{opportunity.title}")
    expect(mail.body.encoded).to include(job_seeker.name)
    expect(mail.body.encoded).to include(job_seeker.email)
    expect(mail.body.encoded).to include(opportunity.title)
  end
end
