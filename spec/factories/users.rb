FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password123' }
    password_confirmation { 'password123' }
    experience_points { 0 }
    level { 1 }
    current_streak { 0 }
    total_trades { 0 }
    profitable_trades { 0 }

    trait :experienced do
      experience_points { 2500 }
      level { 5 }
      total_trades { 25 }
      profitable_trades { 15 }
      current_streak { 3 }
    end

    trait :expert do
      experience_points { 10000 }
      level { 10 }
      total_trades { 100 }
      profitable_trades { 65 }
      current_streak { 8 }
    end

    trait :on_streak do
      current_streak { 5 }
    end
  end
end
