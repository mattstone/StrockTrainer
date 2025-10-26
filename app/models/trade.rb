class Trade < ApplicationRecord
  belongs_to :user
  belongs_to :lesson, optional: true
  belongs_to :stock, foreign_key: :symbol, primary_key: :symbol, optional: true

  validates :symbol, presence: true
  validates :entry_price, presence: true, numericality: { greater_than: 0 }
  validates :position_size, presence: true, numericality: { greater_than: 0 }
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true, inclusion: { in: %w[pending open closed] }
  validates :market_view, presence: true

  validate :stop_loss_validation
  validate :position_size_limit

  before_validation :set_defaults, on: :create
  after_update :update_user_stats, if: :saved_change_to_status?

  scope :profitable, -> { where('pnl > 0') }
  scope :closed, -> { where(status: 'closed') }
  scope :open, -> { where(status: 'open') }

  def profitable?
    pnl.present? && pnl > 0
  end

  def close_trade!(exit_price)
    self.exit_price = exit_price
    self.exit_date = Time.current
    self.pnl = calculate_pnl(exit_price)
    self.status = 'closed'
    save!
  end

  def calculate_pnl(current_price = exit_price)
    return 0 unless current_price && entry_price
    (current_price - entry_price) * quantity
  end

  def percentage_return
    return 0 unless pnl && position_size > 0
    (pnl / position_size * 100).round(2)
  end

  def risk_reward_ratio
    return 0 unless stop_loss && entry_price
    potential_loss = (entry_price - stop_loss) * quantity
    return 0 if potential_loss <= 0
    pnl.abs / potential_loss.abs
  end

  def duration_in_days
    return 0 unless exit_date && entry_date
    (exit_date - entry_date) / 1.day
  end

  private

  def set_defaults
    self.status ||= 'pending'
    self.entry_date ||= Time.current
    self.position_size ||= entry_price * quantity if entry_price && quantity
  end

  def stop_loss_validation
    return unless stop_loss && entry_price
    return if stop_loss < entry_price
    errors.add(:stop_loss, 'must be less than entry price for long positions')
  end

  def position_size_limit
    return unless user && position_size
    max_position = user.total_portfolio_value * 0.05 # 5% max position size
    return if position_size <= max_position
    errors.add(:position_size, 'cannot exceed 5% of total portfolio value')
  end

  def update_user_stats
    return unless status == 'closed'

    user.increment!(:total_trades)
    user.increment!(:profitable_trades) if profitable?

    # Update streak
    if profitable?
      user.increment!(:current_streak)
    else
      user.update!(current_streak: 0)
    end
  end
end
