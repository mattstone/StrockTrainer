class Lesson < ApplicationRecord
  has_many :trades, dependent: :nullify
  has_many :user_lessons, dependent: :destroy
  has_many :users, through: :user_lessons

  validates :title, presence: true
  validates :content, presence: true
  validates :xp_reward, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :required_level, presence: true, numericality: { greater_than_or_equal_to: 1 }
  validates :position, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :published, -> { where(published: true) }
  scope :available_for_level, ->(level) { where('required_level <= ?', level) }
  scope :ordered, -> { order(:position) }

  before_validation :set_defaults, on: :create

  def available_for?(user)
    user.level >= required_level
  end

  def completed_by?(user)
    user_lessons.where(user: user).where.not(completed_at: nil).exists?
  end

  def has_practice_trade?
    practice_trade_enabled || false
  end

  private

  def set_defaults
    self.published = true if published.nil?
    self.required_level ||= 1
    self.xp_reward ||= 50
    self.difficulty ||= 'beginner'
    self.category ||= 'basics'
    self.estimated_duration ||= 10
  end
end
