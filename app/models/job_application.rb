class JobApplication < ApplicationRecord
  belongs_to :job_seeker
  belongs_to :opportunity
end
