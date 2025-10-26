class UsersController < ApplicationController
  def new
    redirect_to dashboard_path if logged_in?
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      # Create a starting portfolio
      @user.portfolios.create!(
        portfolio_type: 'growth',
        total_value: 10000.00,
        initial_value: 10000.00,
        risk_score: 5.0
      )

      log_in_user(@user)
      flash[:notice] = "Welcome to Stock Trainer! Your account has been created with a $10,000 virtual portfolio."
      redirect_to dashboard_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
