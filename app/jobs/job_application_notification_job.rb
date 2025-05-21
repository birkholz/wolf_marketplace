class JobApplicationNotificationJob < ApplicationJob
  queue_as :mailers

  def perform(application_id)
    application = JobApplication.find(application_id)
    JobApplicationMailer.new_application_notification(application).deliver_now
  end
end
