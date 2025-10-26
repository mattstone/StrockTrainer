class LessonsController < ApplicationController
  before_action :require_login
  before_action :set_lesson, only: [:show, :complete]

  def index
    @lessons = Lesson.includes(:user_lessons)
                    .available_for_level(current_user.level)
                    .published
                    .ordered
  end

  def show
    # Check if lesson is available for user's level
    unless @lesson.available_for?(current_user)
      redirect_to lessons_path, alert: "This lesson requires Level #{@lesson.required_level}. Complete more lessons to unlock it!"
      return
    end

    # Get previous and next lessons for navigation
    @previous_lesson = Lesson.where("position < ?", @lesson.position)
                            .available_for_level(current_user.level)
                            .published
                            .order(position: :desc)
                            .first

    @next_lesson = Lesson.where("position > ?", @lesson.position)
                         .available_for_level(current_user.level)
                         .published
                         .order(position: :asc)
                         .first

    # Get related lessons from same category
    @related_lessons = Lesson.where(category: @lesson.category)
                             .where.not(id: @lesson.id)
                             .available_for_level(current_user.level)
                             .published
                             .limit(4)
  end

  def complete
    # Check if lesson is available and not already completed
    unless @lesson.available_for?(current_user)
      redirect_to lessons_path, alert: "This lesson is not available for your level."
      return
    end

    if @lesson.completed_by?(current_user)
      redirect_to lesson_path(@lesson), notice: "You have already completed this lesson."
      return
    end

    # Mark lesson as completed and award XP
    begin
      ActiveRecord::Base.transaction do
        # Create completion record
        UserLesson.create!(
          user: current_user,
          lesson: @lesson,
          completed_at: Time.current,
          xp_earned: @lesson.xp_reward
        )

        # Award XP to user
        current_user.add_experience!(@lesson.xp_reward)

        # Check for lesson completion badges
        BadgeService.new(current_user).check_lesson_badges!
      end

      redirect_to lesson_path(@lesson), notice: "Congratulations! You completed the lesson and earned #{@lesson.xp_reward} XP!"
    rescue => e
      Rails.logger.error "Error completing lesson: #{e.message}"
      redirect_to lesson_path(@lesson), alert: "There was an error completing the lesson. Please try again."
    end
  end

  private

  def set_lesson
    @lesson = Lesson.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to lessons_path, alert: "Lesson not found."
  end
end