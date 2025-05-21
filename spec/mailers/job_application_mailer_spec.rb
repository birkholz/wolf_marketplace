require "rails_helper"

RSpec.describe JobApplicationMailer, type: :mailer do
  describe "new_application" do
    let(:client) { create(:client, email: "client@example.com") }
    let(:job_seeker) { create(:job_seeker, name: "John Doe", email: "john@example.com") }
    let(:opportunity) { create(:opportunity, title: "Registered Nurse", client: client) }
    let(:application) { create(:job_application, job_seeker: job_seeker, opportunity: opportunity) }

    let(:mail) { described_class.new_application(application.id) }

    it "renders the headers" do
      expect(mail.subject).to eq("New Job Application for Registered Nurse")
      expect(mail.to).to eq([ "client@example.com" ])
      expect(mail.from).to eq([ "no-reply@example.com" ])
    end

    it "renders the body" do
      expect(mail.body.encoded).to include("John Doe")
      expect(mail.body.encoded).to include("john@example.com")
      expect(mail.body.encoded).to include("Registered Nurse")
    end
  end
end
