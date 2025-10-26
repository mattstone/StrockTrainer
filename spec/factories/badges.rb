FactoryBot.define do
  factory :badge do
    sequence(:name) { |n| "Test Badge #{n}" }
    description { Faker::Lorem.paragraph }
    icon_class { 'fas fa-trophy' }
    criteria { Faker::Lorem.sentence }
    points_required { Faker::Number.between(from: 100, to: 1000) }

    trait :first_steps do
      name { 'First Steps' }
      description { 'Complete your first trade' }
      icon_class { 'fas fa-baby' }
      criteria { 'Execute 1 trade' }
      points_required { 0 }
    end

    trait :disciplined_trader do
      name { 'Disciplined Trader' }
      description { 'Use stop losses on 10 consecutive trades' }
      icon_class { 'fas fa-shield-alt' }
      criteria { 'Use stop losses on last 10 trades' }
      points_required { 200 }
    end

    trait :profit_streak do
      name { 'Profit Streak' }
      description { 'Achieve a 5-trade winning streak' }
      icon_class { 'fas fa-fire' }
      criteria { 'Win 5 trades in a row' }
      points_required { 250 }
    end
  end
end
