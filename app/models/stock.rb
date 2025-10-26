class Stock < ApplicationRecord
  has_many :trades, foreign_key: :symbol, primary_key: :symbol

  validates :symbol, presence: true, uniqueness: true
  validates :name, presence: true
  validates :current_price, presence: true, numericality: { greater_than: 0 }
  validates :sector, presence: true

  scope :by_sector, ->(sector) { where(sector: sector) }
  scope :updated_recently, -> { where('last_updated > ?', 1.hour.ago) }

  def price_change_percentage(timeframe_hours = 24)
    # This would typically fetch historical data
    # For now, returning a simulated value
    rand(-5.0..5.0).round(2)
  end

  def needs_update?
    last_updated.nil? || last_updated < 15.minutes.ago
  end

  def update_price!(new_price)
    update!(
      current_price: new_price,
      last_updated: Time.current
    )
  end

  def formatted_market_cap
    return 'N/A' unless market_cap

    case market_cap
    when 0..1_000_000_000
      "#{(market_cap / 1_000_000.0).round(1)}M"
    when 1_000_000_000..1_000_000_000_000
      "#{(market_cap / 1_000_000_000.0).round(1)}B"
    else
      "#{(market_cap / 1_000_000_000_000.0).round(1)}T"
    end
  end
end
