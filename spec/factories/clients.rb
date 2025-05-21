FactoryBot.define do
  factory :client do
    sequence(:email) { |n| "client#{n}@example.com" }
    password { "password123" }
    sequence(:name) { |n| "Company #{n}" }
  end
end
