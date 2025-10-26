class Portfolio < ApplicationRecord
  belongs_to :user
  has_many :trades, through: :user

  validates :portfolio_type, presence: true, inclusion: { in: %w[growth income balanced] }
  validates :total_value, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :initial_value, presence: true, numericality: { greater_than: 0 }
  validates :risk_score, numericality: { in: 0..10 }

  before_validation :set_defaults, on: :create

  def total_return
    return 0 if initial_value.zero?
    ((total_value - initial_value) / initial_value * 100).round(2)
  end

  def total_return_amount
    total_value - initial_value
  end

  def update_value!
    # Calculate portfolio value based on current positions
    portfolio_trades = user.trades.closed.where(created_at: created_at..)
    new_value = initial_value + portfolio_trades.sum(:pnl)
    update!(total_value: [new_value, 0].max) # Prevent negative portfolio
  end

  def performance_color
    return 'text-green-600' if total_return > 0
    return 'text-red-600' if total_return < 0
    'text-gray-600'
  end

  private

  def set_defaults
    self.portfolio_type ||= 'growth'
    self.total_value ||= 10000 # Start with $10,000
    self.initial_value ||= 10000
    self.risk_score ||= 5
  end
end
