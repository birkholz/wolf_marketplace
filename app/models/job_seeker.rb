class JobSeeker < ApplicationRecord
  has_many :job_applications
  has_many :opportunities, through: :job_applications
  has_secure_password

  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || password.present? }

  def jwt_subject
    id
  end
end
