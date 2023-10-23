class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  def default_url_options
    { host: ENV["DOMAIN"] || "localhost:3000" }
  end

  before_action :set_unread_notifications_count


  before_action :configure_permitted_parameters, if: :devise_controller?

  private

  def set_unread_notifications_count
    if user_signed_in?
      @unread_notifications_count = Notification.where(recipient_id: current_user.id, read: false).count
      Rails.logger.info "Unread Notifications Count: #{@unread_notifications_count}"
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
  end
end
