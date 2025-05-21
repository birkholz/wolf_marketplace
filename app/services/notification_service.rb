class NotificationService
  def self.notify_new_application(application)
    JobApplicationNotificationJob.perform_later(application.id)
  end
end
