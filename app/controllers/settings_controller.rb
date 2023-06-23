class SettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:email_password, :update_email_password, :profile, :update_profile, :privacy, :update_privacy]

  def index
    user = current_user
  end

  def email_password; end

  def update_email_password
    if @user.update_with_password(email_password_params)
      bypass_sign_in(@user)
      flash[:notice] = 'Email and Password updated successfully'
      redirect_to email_password_settings_path
    else
      flash.now[:error] = @user.errors.full_messages.join(", ")
      render :email_password
    end
  end


  def profile; end

  def update_profile
    if @user.update(profile_params)
      redirect_to profile_settings_path, notice: 'Profile updated successfully'
    else
      render :profile
    end
  end

  def privacy; end

  def update_privacy
    if @user.update(privacy_params)
      redirect_to privacy_settings_path, notice: 'Privacy settings updated successfully'
    else
      render :privacy
    end
  end

  private

  def set_user
    @user = current_user
  end

  def email_password_params
    params.require(:user).permit(:email, :password, :password_confirmation, :current_password)
  end


  def profile_params
    params.require(:user).permit(:username, :photo)
  end

  def privacy_params
    params.require(:user).permit(:privacy)
  end

end
