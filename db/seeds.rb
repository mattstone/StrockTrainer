# Stock Trainer Game Seeds
# This creates initial data for the trading simulation game

puts "🚀 Seeding Stock Trainer Game Data..."

# Create popular stocks for trading
stocks_data = [
  { symbol: 'AAPL', name: 'Apple Inc.', current_price: 150.25, sector: 'Technology', market_cap: 2_500_000_000_000 },
  { symbol: 'GOOGL', name: 'Alphabet Inc.', current_price: 125.50, sector: 'Technology', market_cap: 1_600_000_000_000 },
  { symbol: 'MSFT', name: 'Microsoft Corporation', current_price: 305.75, sector: 'Technology', market_cap: 2_300_000_000_000 },
  { symbol: 'AMZN', name: 'Amazon.com Inc.', current_price: 135.20, sector: 'Consumer Discretionary', market_cap: 1_400_000_000_000 },
  { symbol: 'TSLA', name: 'Tesla Inc.', current_price: 210.30, sector: 'Automotive', market_cap: 650_000_000_000 },
  { symbol: 'NVDA', name: 'NVIDIA Corporation', current_price: 450.80, sector: 'Technology', market_cap: 1_100_000_000_000 },
  { symbol: 'META', name: 'Meta Platforms Inc.', current_price: 285.60, sector: 'Technology', market_cap: 750_000_000_000 },
  { symbol: 'NFLX', name: 'Netflix Inc.', current_price: 380.45, sector: 'Entertainment', market_cap: 170_000_000_000 },
  { symbol: 'SPY', name: 'SPDR S&P 500 ETF', current_price: 420.15, sector: 'ETF', market_cap: 400_000_000_000 },
  { symbol: 'QQQ', name: 'Invesco QQQ Trust', current_price: 350.90, sector: 'ETF', market_cap: 180_000_000_000 }
]

stocks_data.each do |stock_data|
  stock = Stock.find_or_create_by(symbol: stock_data[:symbol]) do |s|
    s.name = stock_data[:name]
    s.current_price = stock_data[:current_price]
    s.sector = stock_data[:sector]
    s.market_cap = stock_data[:market_cap]
    s.last_updated = Time.current
  end
  puts "📈 Created stock: #{stock.symbol} - #{stock.name}"
end

# Create badges for gamification
badges_data = [
  {
    name: 'First Steps',
    description: 'Complete your first trade',
    icon_class: 'fas fa-baby',
    criteria: 'Execute 1 trade',
    points_required: 0
  },
  {
    name: 'Knowledge Seeker',
    description: 'Complete your first lesson',
    icon_class: 'fas fa-book',
    criteria: 'Complete 1 lesson',
    points_required: 50
  },
  {
    name: 'Profitable Trader',
    description: 'Make 3 profitable trades',
    icon_class: 'fas fa-chart-line',
    criteria: 'Execute 3 profitable trades',
    points_required: 100
  },
  {
    name: 'Disciplined Trader',
    description: 'Use stop losses on 10 consecutive trades',
    icon_class: 'fas fa-shield-alt',
    criteria: 'Use stop losses on last 10 trades',
    points_required: 200
  },
  {
    name: 'Risk Manager',
    description: 'Keep position sizes under 3% for 20 trades',
    icon_class: 'fas fa-hard-hat',
    criteria: 'Position size < 3% on last 20 trades',
    points_required: 500
  },
  {
    name: 'Profit Streak',
    description: 'Achieve a 5-trade winning streak',
    icon_class: 'fas fa-fire',
    criteria: 'Win 5 trades in a row',
    points_required: 250
  },
  {
    name: 'Hot Streak',
    description: 'Achieve a 10-trade winning streak',
    icon_class: 'fas fa-meteor',
    criteria: 'Win 10 trades in a row',
    points_required: 750
  },
  {
    name: 'Legendary Streak',
    description: 'Achieve a 20-trade winning streak',
    icon_class: 'fas fa-crown',
    criteria: 'Win 20 trades in a row',
    points_required: 2000
  },
  {
    name: 'Consistent Trader',
    description: 'Maintain 60%+ win rate with 25+ trades',
    icon_class: 'fas fa-target',
    criteria: '60% win rate with 25+ trades',
    points_required: 1000
  },
  {
    name: 'Learning Master',
    description: 'Complete 10 lessons',
    icon_class: 'fas fa-graduation-cap',
    criteria: 'Complete 10 lessons',
    points_required: 500
  },
  {
    name: 'Scholar',
    description: 'Complete 25 lessons',
    icon_class: 'fas fa-user-graduate',
    criteria: 'Complete 25 lessons',
    points_required: 1250
  },
  {
    name: 'Rising Star',
    description: 'Reach level 5',
    icon_class: 'fas fa-star',
    criteria: 'Reach user level 5',
    points_required: 5000
  },
  {
    name: 'Experienced Trader',
    description: 'Reach level 10',
    icon_class: 'fas fa-medal',
    criteria: 'Reach user level 10',
    points_required: 10000
  },
  {
    name: 'Expert Trader',
    description: 'Reach level 20',
    icon_class: 'fas fa-trophy',
    criteria: 'Reach user level 20',
    points_required: 20000
  },
  {
    name: 'Master Trader',
    description: 'Reach level 50',
    icon_class: 'fas fa-crown',
    criteria: 'Reach user level 50',
    points_required: 50000
  },
  {
    name: 'Volume Trader',
    description: 'Execute 100 trades',
    icon_class: 'fas fa-chart-bar',
    criteria: 'Execute 100 trades',
    points_required: 2500
  },
  {
    name: 'XP Collector',
    description: 'Earn 1,000 XP',
    icon_class: 'fas fa-coins',
    criteria: 'Earn 1,000 experience points',
    points_required: 1000
  },
  {
    name: 'XP Master',
    description: 'Earn 5,000 XP',
    icon_class: 'fas fa-gem',
    criteria: 'Earn 5,000 experience points',
    points_required: 5000
  },
  {
    name: 'XP Legend',
    description: 'Earn 25,000 XP',
    icon_class: 'fas fa-diamond',
    criteria: 'Earn 25,000 experience points',
    points_required: 25000
  }
]

badges_data.each do |badge_data|
  badge = Badge.find_or_create_by(name: badge_data[:name]) do |b|
    b.description = badge_data[:description]
    b.icon_class = badge_data[:icon_class]
    b.criteria = badge_data[:criteria]
    b.points_required = badge_data[:points_required]
  end
  puts "🏆 Created badge: #{badge.name}"
end

# Create sample lessons
lessons_data = [
  {
    title: 'Introduction to Stock Markets',
    content: %{
      <h2>Welcome to Stock Trading!</h2>
      <p>The stock market is where shares of public companies are bought and sold. When you buy a stock, you're purchasing a small piece of ownership in that company.</p>

      <h3>Key Concepts:</h3>
      <ul>
        <li><strong>Stock Price:</strong> The current market value of one share</li>
        <li><strong>Market Cap:</strong> Total value of all company shares</li>
        <li><strong>Volume:</strong> Number of shares traded in a period</li>
        <li><strong>Volatility:</strong> How much the price fluctuates</li>
      </ul>

      <h3>Your First Trade</h3>
      <p>Let's practice with Apple (AAPL). Think about why you want to buy or sell this stock, then place your first trade!</p>

      <div class="bg-blue-100 p-4 rounded">
        <strong>💡 Tip:</strong> Always have a reason for your trades and set a stop loss to manage risk!
      </div>
    },
    xp_reward: 50,
    unlock_level: 1,
    position: 1
  },
  {
    title: 'Understanding Risk Management',
    content: %{
      <h2>Risk Management: Your Best Friend</h2>
      <p>Risk management is the most important skill in trading. It's not about being right all the time - it's about managing your losses when you're wrong.</p>

      <h3>The 1% Rule</h3>
      <p>Never risk more than 1-2% of your total portfolio on a single trade. This means if you have $10,000, you should only risk $100-200 per trade.</p>

      <h3>Stop Losses</h3>
      <p>A stop loss is a predetermined price where you'll exit a losing trade. It's like insurance for your trades.</p>

      <h4>Example:</h4>
      <ul>
        <li>Buy AAPL at $150</li>
        <li>Set stop loss at $145 (3.33% loss)</li>
        <li>If price drops to $145, automatically sell</li>
        <li>Maximum loss: $5 per share</li>
      </ul>

      <h3>Position Sizing</h3>
      <p>Calculate your position size based on your risk tolerance:</p>
      <code>Position Size = Risk Amount / (Entry Price - Stop Loss)</code>

      <div class="bg-red-100 p-4 rounded">
        <strong>⚠️ Remember:</strong> Preserve capital first, make profits second!
      </div>
    },
    xp_reward: 75,
    unlock_level: 1,
    position: 2
  },
  {
    title: 'Reading Stock Charts',
    content: %{
      <h2>Technical Analysis Basics</h2>
      <p>Charts tell the story of a stock's price movement. Learning to read them gives you insights into market sentiment and potential future movements.</p>

      <h3>Candlestick Charts</h3>
      <p>Each candlestick shows:</p>
      <ul>
        <li><strong>Open:</strong> Price when trading period started</li>
        <li><strong>Close:</strong> Price when trading period ended</li>
        <li><strong>High:</strong> Highest price during the period</li>
        <li><strong>Low:</strong> Lowest price during the period</li>
      </ul>

      <h3>Support and Resistance</h3>
      <ul>
        <li><strong>Support:</strong> Price level where stock tends to stop falling</li>
        <li><strong>Resistance:</strong> Price level where stock tends to stop rising</li>
      </ul>

      <h3>Moving Averages</h3>
      <p>Moving averages smooth out price action to show the overall trend:</p>
      <ul>
        <li><strong>50-day MA:</strong> Shows medium-term trend</li>
        <li><strong>200-day MA:</strong> Shows long-term trend</li>
      </ul>

      <h3>Practice Exercise</h3>
      <p>Look at the GOOGL chart and identify:</p>
      <ol>
        <li>Current trend direction</li>
        <li>Support/resistance levels</li>
        <li>Good entry points</li>
      </ol>

      <div class="bg-green-100 p-4 rounded">
        <strong>📊 Pro Tip:</strong> The trend is your friend - trade with it, not against it!
      </div>
    },
    xp_reward: 100,
    unlock_level: 2,
    position: 3
  },
  {
    title: 'Market Psychology & Emotions',
    content: %{
      <h2>Mastering Your Trading Psychology</h2>
      <p>The biggest enemy in trading isn't the market - it's your own emotions. Fear and greed can destroy even the best trading strategies.</p>

      <h3>Common Emotional Traps</h3>

      <h4>1. Fear of Missing Out (FOMO)</h4>
      <p>Jumping into trades because everyone else is making money leads to buying at peaks.</p>

      <h4>2. Revenge Trading</h4>
      <p>Trying to quickly recover losses by taking bigger risks usually makes things worse.</p>

      <h4>3. Overconfidence</h4>
      <p>A few winning trades can make you feel invincible and take unnecessary risks.</p>

      <h4>4. Analysis Paralysis</h4>
      <p>Overthinking and missing good opportunities while searching for the "perfect" trade.</p>

      <h3>Building Discipline</h3>
      <ul>
        <li>Stick to your trading plan</li>
        <li>Keep a trading journal</li>
        <li>Review your trades regularly</li>
        <li>Accept that losses are part of trading</li>
        <li>Never trade with money you can't afford to lose</li>
      </ul>

      <h3>The Trading Journal</h3>
      <p>For each trade, record:</p>
      <ul>
        <li>Why you entered</li>
        <li>Your market view</li>
        <li>Entry/exit prices</li>
        <li>What you learned</li>
      </ul>

      <div class="bg-purple-100 p-4 rounded">
        <strong>🧠 Mental Note:</strong> Successful trading is 20% strategy and 80% psychology!
      </div>
    },
    xp_reward: 100,
    unlock_level: 3,
    position: 4
  },
  {
    title: 'Building Your Trading Strategy',
    content: %{
      <h2>Developing Your Trading Edge</h2>
      <p>A trading strategy is your roadmap to consistent profits. It defines when to enter, when to exit, and how to manage risk.</p>

      <h3>Components of a Good Strategy</h3>

      <h4>1. Market Analysis</h4>
      <ul>
        <li><strong>Fundamental:</strong> Company earnings, news, economic data</li>
        <li><strong>Technical:</strong> Chart patterns, indicators, price action</li>
      </ul>

      <h4>2. Entry Rules</h4>
      <p>Clear conditions for when to open a position:</p>
      <ul>
        <li>Breakout above resistance</li>
        <li>Bounce off support</li>
        <li>Moving average crossover</li>
        <li>News catalyst + technical setup</li>
      </ul>

      <h4>3. Exit Rules</h4>
      <ul>
        <li><strong>Stop Loss:</strong> Where to cut losses</li>
        <li><strong>Take Profit:</strong> Where to secure gains</li>
        <li><strong>Time-based:</strong> How long to hold</li>
      </ul>

      <h4>4. Position Sizing</h4>
      <p>How much to risk on each trade based on your account size and risk tolerance.</p>

      <h3>Sample Strategy: Trend Following</h3>
      <ol>
        <li><strong>Setup:</strong> Stock above 50-day moving average</li>
        <li><strong>Entry:</strong> Breakout above previous day's high</li>
        <li><strong>Stop:</strong> Below previous day's low</li>
        <li><strong>Target:</strong> 2:1 risk/reward ratio</li>
        <li><strong>Size:</strong> Risk 1% of account</li>
      </ol>

      <h3>Testing Your Strategy</h3>
      <p>Before risking real money:</p>
      <ul>
        <li>Backtest on historical data</li>
        <li>Paper trade for 30+ trades</li>
        <li>Track your win rate and profitability</li>
        <li>Refine based on results</li>
      </ul>

      <div class="bg-yellow-100 p-4 rounded">
        <strong>⚡ Key Insight:</strong> The best strategy is one you can follow consistently!
      </div>
    },
    xp_reward: 125,
    unlock_level: 4,
    position: 5
  }
]

lessons_data.each do |lesson_data|
  lesson = Lesson.find_or_create_by(title: lesson_data[:title]) do |l|
    l.content = lesson_data[:content]
    l.description = lesson_data[:description]
    l.category = lesson_data[:category]
    l.difficulty = lesson_data[:difficulty]
    l.estimated_duration = lesson_data[:estimated_duration]
    l.learning_objectives = lesson_data[:learning_objectives]
    l.practice_trade_enabled = lesson_data[:practice_trade_enabled]
    l.xp_reward = lesson_data[:xp_reward]
    l.required_level = lesson_data[:required_level]
    l.position = lesson_data[:position]
    l.published = true
  end
  puts "📚 Created lesson: #{lesson.title}"
end

# Create a demo user for testing
demo_user = User.find_or_create_by(email: 'demo@stocktrainer.com') do |u|
  u.password = 'password123'
  u.password_confirmation = 'password123'
  u.experience_points = 150
  u.level = 2
  u.current_streak = 0
  u.total_trades = 0
  u.profitable_trades = 0
end

if demo_user.persisted?
  puts "👤 Created demo user: #{demo_user.email}"

  # Create a starting portfolio for the demo user
  portfolio = Portfolio.find_or_create_by(user: demo_user, portfolio_type: 'growth') do |p|
    p.total_value = 10000.00
    p.initial_value = 10000.00
    p.risk_score = 5.0
  end
  puts "💼 Created portfolio for demo user: $#{portfolio.total_value}"
end

puts "✅ Seeding completed successfully!"
puts ""
puts "🎮 Stock Trainer Game is ready to play!"
puts "📧 Demo login: demo@stocktrainer.com"
puts "🔑 Password: password123"
puts "💰 Starting portfolio: $10,000"
puts "📊 Available stocks: #{Stock.count}"
puts "🏆 Available badges: #{Badge.count}"
puts "📚 Available lessons: #{Lesson.count}"
