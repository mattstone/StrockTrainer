class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Include Pagy for pagination
  include Pagy::Backend

  # Session management
  before_action :current_user

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def logged_in?
    !!current_user
  end

  def require_login
    unless logged_in?
      flash[:alert] = "You must be logged in to access this page."
      redirect_to login_path
    end
  end

  def log_in_user(user)
    session[:user_id] = user.id
    @current_user = user
  end

  def log_out_user
    session[:user_id] = nil
    @current_user = nil
  end

  helper_method :current_user, :logged_in?
end
