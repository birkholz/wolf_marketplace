class AddJobSeekerAndOpportunityToJobApplications < ActiveRecord::Migration[8.0]
  def change
    add_reference :job_applications, :job_seeker, null: false, foreign_key: true
    add_reference :job_applications, :opportunity, null: false, foreign_key: true
  end
end
