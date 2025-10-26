FactoryBot.define do
  factory :portfolio do
    association :user
    portfolio_type { 'growth' }
    total_value { 10000.00 }
    initial_value { 10000.00 }
    risk_score { 5.0 }

    trait :profitable do
      total_value { 12000.00 }
    end

    trait :losing do
      total_value { 8000.00 }
    end

    trait :income_focused do
      portfolio_type { 'income' }
      risk_score { 3.0 }
    end

    trait :aggressive do
      portfolio_type { 'balanced' }
      risk_score { 8.0 }
    end

    trait :large_account do
      total_value { 100000.00 }
      initial_value { 100000.00 }
    end
  end
end
