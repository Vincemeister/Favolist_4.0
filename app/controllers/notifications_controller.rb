class NotificationsController < ApplicationController
  before_action :authenticate_user!


  def index
    @notifications = current_user.notifications_received.order(created_at: :desc)
  end

  def mark_as_read
    @notification = Notification.find(params[:id])
    @notification.mark_as_read
    render json: { success: @notification.read? }
  end

  def clear_all
    current_user.notifications_received.delete_all
    redirect_to notifications_path, notice: 'All notifications cleared.'
  end
end
