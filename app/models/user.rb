class User < ApplicationRecord
  has_secure_password

  has_many :trades, dependent: :destroy
  has_many :portfolios, dependent: :destroy
  has_many :user_badges, dependent: :destroy
  has_many :badges, through: :user_badges
  has_many :user_lessons, dependent: :destroy
  has_many :completed_lessons, -> { where.not(user_lessons: { completed_at: nil }) }, through: :user_lessons, source: :lesson

  validates :email, presence: true, uniqueness: true
  validates :experience_points, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :level, presence: true, numericality: { greater_than_or_equal_to: 1 }
  validates :current_streak, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :total_trades, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :profitable_trades, presence: true, numericality: { greater_than_or_equal_to: 0 }

  before_validation :set_defaults, on: :create

  def win_rate
    return 0 if total_trades.zero?
    (profitable_trades.to_f / total_trades * 100).round(2)
  end

  def next_level_xp
    level * 1000
  end

  def progress_to_next_level
    return 100 if experience_points >= next_level_xp
    (experience_points.to_f / next_level_xp * 100).round(1)
  end

  def level_up_if_eligible!
    while experience_points >= next_level_xp
      update!(level: level + 1)
    end
  end

  def add_experience!(points)
    update!(experience_points: experience_points + points)
    level_up_if_eligible!
  end

  def total_portfolio_value
    portfolios.sum(:total_value)
  end

  def completed_lessons_count
    user_lessons.where.not(completed_at: nil).count
  end

  private

  def set_defaults
    self.experience_points ||= 0
    self.level ||= 1
    self.current_streak ||= 0
    self.total_trades ||= 0
    self.profitable_trades ||= 0
  end
end
