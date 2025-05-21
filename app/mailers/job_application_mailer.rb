class JobApplicationMailer < ApplicationMailer
  def new_application_notification(application)
    @application = application
    @opportunity = application.opportunity
    @client = @opportunity.client
    @job_seeker = application.job_seeker

    mail(
      to: @client.email,
      subject: "New application for #{@opportunity.title}"
    )
  end
end
