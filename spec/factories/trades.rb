FactoryBot.define do
  factory :trade do
    association :user
    symbol { 'AAPL' }
    entry_price { 150.00 }
    stop_loss { 145.00 }
    position_size { 300.00 } # 3% of default 10k portfolio
    quantity { 2 }
    status { 'open' }
    entry_date { Time.current }
    market_view { 'Bullish on tech sector growth' }

    # Create portfolio for the user after user is created
    after(:build) do |trade|
      create(:portfolio, user: trade.user, total_value: 10000) unless trade.user.portfolios.any?
    end

    trait :closed_profitable do
      status { 'closed' }
      exit_price { 155.00 }
      exit_date { 1.day.from_now }
      pnl { 10.00 } # (155 - 150) * 2 = 10
    end

    trait :closed_loss do
      status { 'closed' }
      exit_price { 145.00 }
      exit_date { 1.day.from_now }
      pnl { -10.00 } # (145 - 150) * 2 = -10
    end

    trait :pending do
      status { 'pending' }
      entry_date { nil }
    end

    trait :with_lesson do
      association :lesson
    end

    trait :large_position do
      quantity { 4 }
      position_size { 600.00 } # 6% - above the 5% limit
    end

    trait :no_stop_loss do
      stop_loss { nil }
    end
  end
end
