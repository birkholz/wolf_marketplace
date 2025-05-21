FactoryBot.define do
  factory :opportunity do
    sequence(:title) { |n| "Job Title #{n}" }
    description { Faker::Lorem.paragraph }
    salary { Faker::Number.between(from: 50000, to: 200000) }
    association :client
  end
end
