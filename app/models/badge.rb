class Badge < ApplicationRecord
  has_many :user_badges, dependent: :destroy
  has_many :users, through: :user_badges

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
  validates :icon_class, presence: true
  validates :criteria, presence: true
  validates :points_required, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :achievable_by, ->(user) { where('points_required <= ?', user.experience_points) }

  def earned_by?(user)
    user_badges.exists?(user: user)
  end

  def award_to!(user)
    return if earned_by?(user)

    user_badges.create!(user: user, earned_at: Time.current)
    user.add_experience!(25) # Bonus XP for earning badge
  end
end
