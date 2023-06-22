class SettingsController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
  end

  def update
    @user = current_user
    @user.update(user_params)

    redirect_to settings_path
  end

  private

  def user_params
    params.require(:user).permit(:username, :email, :photo)
  end

end
