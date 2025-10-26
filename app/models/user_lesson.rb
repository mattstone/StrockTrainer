class UserLesson < ApplicationRecord
  belongs_to :user
  belongs_to :lesson

  validates :user_id, uniqueness: { scope: :lesson_id }
  validates :xp_earned, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :completed, -> { where.not(completed_at: nil) }
  scope :in_progress, -> { where(completed_at: nil) }
end
