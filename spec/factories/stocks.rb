FactoryBot.define do
  factory :stock do
    sequence(:symbol) { |n| "STOCK#{n}" }
    sequence(:name) { |n| "Test Company #{n} Inc." }
    current_price { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
    last_updated { Time.current }
    sector { ['Technology', 'Healthcare', 'Finance', 'Energy', 'Consumer'].sample }
    market_cap { Faker::Number.number(digits: 12) }

    trait :aapl do
      symbol { 'AAPL' }
      name { 'Apple Inc.' }
      current_price { 150.25 }
      sector { 'Technology' }
      market_cap { 2_500_000_000_000 }
    end

    trait :googl do
      symbol { 'GOOGL' }
      name { 'Alphabet Inc.' }
      current_price { 125.50 }
      sector { 'Technology' }
      market_cap { 1_600_000_000_000 }
    end

    trait :expensive do
      current_price { Faker::Number.between(from: 500, to: 1000) }
    end

    trait :cheap do
      current_price { Faker::Number.between(from: 1, to: 50) }
    end
  end
end
