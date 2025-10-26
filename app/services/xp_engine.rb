class XpEngine
  attr_reader :user

  XP_REWARDS = {
    lesson_complete: 50,
    profitable_trade: 25,
    trade_with_stop: 10,
    badge_earned: 25,
    level_up: 100,
    streak_bonus: 5 # per trade in streak
  }.freeze

  XP_PENALTIES = {
    trade_without_stop: -15,
    oversized_position: -10,
    loss_above_threshold: -5 # if loss > 5% of position
  }.freeze

  def initialize(user)
    @user = user
  end

  def award_lesson_xp(lesson)
    award_xp(XP_REWARDS[:lesson_complete], "Completed lesson: #{lesson.title}")
  end

  def award_trade_xp(trade)
    total_xp = 0

    # Base trade completion XP
    if trade.profitable?
      total_xp += XP_REWARDS[:profitable_trade]
      total_xp += calculate_streak_bonus
    end

    # Risk management bonuses/penalties
    total_xp += calculate_risk_management_xp(trade)

    # Performance bonuses
    total_xp += calculate_performance_bonus(trade)

    award_xp(total_xp, "Trade #{trade.symbol}: #{trade.profitable? ? 'Profit' : 'Loss'}")

    # Check for badge eligibility after trade
    check_and_award_trade_badges(trade)
  end

  def award_badge_xp(badge)
    award_xp(XP_REWARDS[:badge_earned], "Badge earned: #{badge.name}")
  end

  private

  def award_xp(points, reason)
    return if points.zero?

    user.add_experience!(points)

    # Log XP award (you could create an XpLog model for this)
    Rails.logger.info "XP Award: #{user.email} +#{points} XP - #{reason}"
  end

  def calculate_streak_bonus
    return 0 if user.current_streak <= 1

    # Escalating bonus for streaks
    case user.current_streak
    when 2..4
      XP_REWARDS[:streak_bonus]
    when 5..9
      XP_REWARDS[:streak_bonus] * 2
    when 10..19
      XP_REWARDS[:streak_bonus] * 3
    else
      XP_REWARDS[:streak_bonus] * 5 # Max bonus for 20+ streaks
    end
  end

  def calculate_risk_management_xp(trade)
    xp = 0

    # Bonus for using stop loss
    if trade.stop_loss.present?
      xp += XP_REWARDS[:trade_with_stop]
    else
      xp += XP_PENALTIES[:trade_without_stop]
    end

    # Penalty for oversized positions
    if oversized_position?(trade)
      xp += XP_PENALTIES[:oversized_position]
    end

    # Penalty for large losses
    if large_loss?(trade)
      xp += XP_PENALTIES[:loss_above_threshold]
    end

    xp
  end

  def calculate_performance_bonus(trade)
    return 0 unless trade.profitable?

    percentage_return = trade.percentage_return

    case percentage_return
    when 10..19
      10 # Good performance
    when 20..49
      20 # Great performance
    when 50..Float::INFINITY
      35 # Exceptional performance
    else
      0
    end
  end

  def oversized_position?(trade)
    max_position = user.total_portfolio_value * 0.05
    trade.position_size > max_position
  end

  def large_loss?(trade)
    return false if trade.profitable?

    loss_percentage = (trade.pnl.abs / trade.position_size * 100)
    loss_percentage > 5
  end

  def check_and_award_trade_badges(trade)
    # Check for various trading badges
    check_disciplined_trader_badge
    check_profit_streak_badge
    check_risk_manager_badge
    check_consistent_trader_badge
  end

  def check_disciplined_trader_badge
    badge = Badge.find_by(name: 'Disciplined Trader')
    return unless badge
    return if badge.earned_by?(user)

    # Check last 10 trades all have stop losses
    recent_trades = user.trades.closed.limit(10).order(created_at: :desc)
    if recent_trades.count >= 10 && recent_trades.all? { |t| t.stop_loss.present? }
      badge.award_to!(user)
    end
  end

  def check_profit_streak_badge
    badge = Badge.find_by(name: 'Profit Streak')
    return unless badge
    return if badge.earned_by?(user)

    if user.current_streak >= 5
      badge.award_to!(user)
    end
  end

  def check_risk_manager_badge
    badge = Badge.find_by(name: 'Risk Manager')
    return unless badge
    return if badge.earned_by?(user)

    # No trades with position size > 3% in last 20 trades
    recent_trades = user.trades.closed.limit(20)
    max_position_allowed = user.total_portfolio_value * 0.03

    if recent_trades.count >= 20 &&
       recent_trades.all? { |t| t.position_size <= max_position_allowed }
      badge.award_to!(user)
    end
  end

  def check_consistent_trader_badge
    badge = Badge.find_by(name: 'Consistent Trader')
    return unless badge
    return if badge.earned_by?(user)

    # Win rate > 60% with at least 25 trades
    if user.total_trades >= 25 && user.win_rate >= 60
      badge.award_to!(user)
    end
  end
end