FactoryBot.define do
  factory :job_application do
    association :opportunity
    association :job_seeker
  end
end
