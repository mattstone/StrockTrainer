class BadgeService
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def check_all_badges
    check_trading_badges
    check_learning_badges
    check_achievement_badges
  end

  def available_badges
    Badge.where.not(id: user.badge_ids)
  end

  def progress_towards_badge(badge)
    case badge.name
    when 'Disciplined Trader'
      disciplined_trader_progress
    when 'Profit Streak'
      profit_streak_progress
    when 'Risk Manager'
      risk_manager_progress
    when 'Consistent Trader'
      consistent_trader_progress
    when 'Learning Master'
      learning_master_progress
    when 'First Steps'
      first_steps_progress
    else
      { current: 0, required: badge.points_required, percentage: 0 }
    end
  end

  private

  def check_trading_badges
    check_first_trade_badge
    check_profitable_trader_badge
    check_disciplined_trader_badge
    check_risk_manager_badge
    check_consistent_trader_badge
    check_volume_trader_badge
  end

  def check_learning_badges
    check_first_lesson_badge
    check_learning_master_badge
    check_knowledge_seeker_badge
  end

  def check_achievement_badges
    check_level_badges
    check_xp_badges
    check_streak_badges
  end

  def check_first_trade_badge
    badge = Badge.find_by(name: 'First Steps')
    return unless badge && !badge.earned_by?(user)

    if user.trades.any?
      badge.award_to!(user)
    end
  end

  def check_profitable_trader_badge
    badge = Badge.find_by(name: 'Profitable Trader')
    return unless badge && !badge.earned_by?(user)

    if user.trades.profitable.count >= 3
      badge.award_to!(user)
    end
  end

  def check_disciplined_trader_badge
    badge = Badge.find_by(name: 'Disciplined Trader')
    return unless badge && !badge.earned_by?(user)

    recent_trades = user.trades.closed.limit(10).order(created_at: :desc)
    if recent_trades.count >= 10 && recent_trades.all? { |t| t.stop_loss.present? }
      badge.award_to!(user)
    end
  end

  def check_risk_manager_badge
    badge = Badge.find_by(name: 'Risk Manager')
    return unless badge && !badge.earned_by?(user)

    recent_trades = user.trades.closed.limit(20)
    max_position_allowed = user.total_portfolio_value * 0.03

    if recent_trades.count >= 20 &&
       recent_trades.all? { |t| t.position_size <= max_position_allowed }
      badge.award_to!(user)
    end
  end

  def check_consistent_trader_badge
    badge = Badge.find_by(name: 'Consistent Trader')
    return unless badge && !badge.earned_by?(user)

    if user.total_trades >= 25 && user.win_rate >= 60
      badge.award_to!(user)
    end
  end

  def check_volume_trader_badge
    badge = Badge.find_by(name: 'Volume Trader')
    return unless badge && !badge.earned_by?(user)

    if user.total_trades >= 100
      badge.award_to!(user)
    end
  end

  def check_first_lesson_badge
    badge = Badge.find_by(name: 'Knowledge Seeker')
    return unless badge && !badge.earned_by?(user)

    completed_lessons = Lesson.joins(:trades).where(trades: { user: user }).distinct.count
    if completed_lessons >= 1
      badge.award_to!(user)
    end
  end

  def check_learning_master_badge
    badge = Badge.find_by(name: 'Learning Master')
    return unless badge && !badge.earned_by?(user)

    completed_lessons = Lesson.joins(:trades).where(trades: { user: user }).distinct.count
    if completed_lessons >= 10
      badge.award_to!(user)
    end
  end

  def check_knowledge_seeker_badge
    badge = Badge.find_by(name: 'Scholar')
    return unless badge && !badge.earned_by?(user)

    completed_lessons = Lesson.joins(:trades).where(trades: { user: user }).distinct.count
    if completed_lessons >= 25
      badge.award_to!(user)
    end
  end

  def check_level_badges
    level_badges = [
      { name: 'Rising Star', level: 5 },
      { name: 'Experienced Trader', level: 10 },
      { name: 'Expert Trader', level: 20 },
      { name: 'Master Trader', level: 50 }
    ]

    level_badges.each do |badge_info|
      badge = Badge.find_by(name: badge_info[:name])
      next unless badge && !badge.earned_by?(user)

      if user.level >= badge_info[:level]
        badge.award_to!(user)
      end
    end
  end

  def check_xp_badges
    xp_badges = [
      { name: 'XP Collector', xp: 1000 },
      { name: 'XP Master', xp: 5000 },
      { name: 'XP Legend', xp: 25000 }
    ]

    xp_badges.each do |badge_info|
      badge = Badge.find_by(name: badge_info[:name])
      next unless badge && !badge.earned_by?(user)

      if user.experience_points >= badge_info[:xp]
        badge.award_to!(user)
      end
    end
  end

  def check_streak_badges
    streak_badges = [
      { name: 'Profit Streak', streak: 5 },
      { name: 'Hot Streak', streak: 10 },
      { name: 'Legendary Streak', streak: 20 }
    ]

    streak_badges.each do |badge_info|
      badge = Badge.find_by(name: badge_info[:name])
      next unless badge && !badge.earned_by?(user)

      if user.current_streak >= badge_info[:streak]
        badge.award_to!(user)
      end
    end
  end

  # Progress calculation methods
  def disciplined_trader_progress
    recent_trades = user.trades.closed.limit(10).order(created_at: :desc)
    trades_with_stops = recent_trades.count { |t| t.stop_loss.present? }

    {
      current: trades_with_stops,
      required: 10,
      percentage: recent_trades.any? ? (trades_with_stops.to_f / [recent_trades.count, 10].min * 100).round(1) : 0
    }
  end

  def profit_streak_progress
    {
      current: user.current_streak,
      required: 5,
      percentage: (user.current_streak.to_f / 5 * 100).round(1).clamp(0, 100)
    }
  end

  def risk_manager_progress
    recent_trades = user.trades.closed.limit(20)
    max_position_allowed = user.total_portfolio_value * 0.03
    conservative_trades = recent_trades.count { |t| t.position_size <= max_position_allowed }

    {
      current: conservative_trades,
      required: 20,
      percentage: recent_trades.any? ? (conservative_trades.to_f / [recent_trades.count, 20].min * 100).round(1) : 0
    }
  end

  def consistent_trader_progress
    {
      current: [user.total_trades, user.win_rate].min,
      required: [25, 60].max,
      percentage: [
        (user.total_trades.to_f / 25 * 50).round(1),
        (user.win_rate.to_f / 60 * 50).round(1)
      ].sum.clamp(0, 100)
    }
  end

  def learning_master_progress
    completed_lessons = Lesson.joins(:trades).where(trades: { user: user }).distinct.count

    {
      current: completed_lessons,
      required: 10,
      percentage: (completed_lessons.to_f / 10 * 100).round(1).clamp(0, 100)
    }
  end

  def first_steps_progress
    {
      current: user.trades.count > 0 ? 1 : 0,
      required: 1,
      percentage: user.trades.any? ? 100 : 0
    }
  end
end