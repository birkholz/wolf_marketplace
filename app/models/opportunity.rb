class Opportunity < ApplicationRecord
  belongs_to :client
  has_many :job_applications
  validates :title, :description, :salary, presence: true
end
