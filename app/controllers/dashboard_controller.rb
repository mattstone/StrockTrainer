class DashboardController < ApplicationController
  before_action :require_login, except: [:index]

  def index
    if logged_in?
      # Dashboard for logged-in users
      @user = current_user
      @portfolio = @user.portfolios.first
      @recent_trades = @user.trades.includes(:lesson).order(created_at: :desc).limit(5)
      @available_lessons = Lesson.available_for_level(@user.level).published.ordered.limit(3)
      @earned_badges = @user.badges.order(created_at: :desc).limit(6)
      @badge_service = BadgeService.new(@user)
      @next_badges = @badge_service.available_badges.limit(3)
    else
      # Landing page for visitors
      render :landing
    end
  end
end
