FactoryBot.define do
  factory :job_seeker do
    sequence(:email) { |n| "jobseeker#{n}@example.com" }
    password { "password123" }
    sequence(:name) { |n| "Job Seeker #{n}" }
  end
end
