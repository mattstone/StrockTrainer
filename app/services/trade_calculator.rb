class TradeCalculator
  attr_reader :trade

  def initialize(trade)
    @trade = trade
  end

  def calculate_pnl(exit_price = nil)
    price = exit_price || trade.exit_price
    return 0 unless price && trade.entry_price && trade.quantity

    (price - trade.entry_price) * trade.quantity
  end

  def calculate_percentage_return(exit_price = nil)
    pnl = calculate_pnl(exit_price)
    return 0 unless trade.position_size > 0

    (pnl / trade.position_size * 100).round(2)
  end

  def calculate_risk_reward_ratio
    return 0 unless trade.stop_loss && trade.entry_price && trade.quantity

    potential_loss = (trade.entry_price - trade.stop_loss) * trade.quantity
    return 0 if potential_loss <= 0

    potential_gain = estimate_potential_gain
    return 0 if potential_gain <= 0

    potential_gain / potential_loss.abs
  end

  def validate_position_size(user)
    max_position = user.total_portfolio_value * 0.05 # 5% max
    trade.position_size <= max_position
  end

  def validate_stop_loss
    return false unless trade.stop_loss && trade.entry_price
    trade.stop_loss < trade.entry_price # Assuming long positions for now
  end

  def calculate_optimal_position_size(user, risk_percentage = 0.01)
    return 0 unless trade.stop_loss && trade.entry_price

    risk_amount = user.total_portfolio_value * risk_percentage
    risk_per_share = trade.entry_price - trade.stop_loss
    return 0 if risk_per_share <= 0

    (risk_amount / risk_per_share).floor
  end

  def update_trade_with_exit!(exit_price, exit_reason = 'manual')
    pnl = calculate_pnl(exit_price)
    percentage_return = calculate_percentage_return(exit_price)

    trade.update!(
      exit_price: exit_price,
      exit_date: Time.current,
      pnl: pnl,
      status: 'closed'
    )

    # Award XP based on trade performance and risk management
    XpEngine.new(trade.user).award_trade_xp(trade)

    trade
  end

  private

  def estimate_potential_gain
    # Simple estimation - could be enhanced with technical analysis
    # For now, assume a 2:1 risk/reward ratio target
    return 0 unless trade.stop_loss && trade.entry_price

    risk_per_share = trade.entry_price - trade.stop_loss
    target_gain_per_share = risk_per_share * 2
    target_gain_per_share * trade.quantity
  end
end