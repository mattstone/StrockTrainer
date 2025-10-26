class UserBadge < ApplicationRecord
  belongs_to :user
  belongs_to :badge

  validates :user_id, uniqueness: { scope: :badge_id }
  validates :earned_at, presence: true

  before_validation :set_earned_at, on: :create

  scope :recent, -> { order(earned_at: :desc) }
  scope :earned_today, -> { where('earned_at > ?', 1.day.ago) }

  private

  def set_earned_at
    self.earned_at ||= Time.current
  end
end
