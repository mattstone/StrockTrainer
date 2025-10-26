class SessionsController < ApplicationController
  def new
    redirect_to dashboard_path if logged_in?
  end

  def create
    user = User.find_by(email: params[:email]&.downcase)

    if user&.authenticate(params[:password])
      log_in_user(user)
      flash[:notice] = "Welcome back, #{user.email}!"
      redirect_to dashboard_path
    else
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    log_out_user
    flash[:notice] = "You have been logged out."
    redirect_to login_path
  end
end
