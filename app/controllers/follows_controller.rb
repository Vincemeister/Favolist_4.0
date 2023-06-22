# Going to move follow actions from user controller to here for separation of concerns later
class FollowsController < ApplicationController
  # before_action :set_user, only: [:create, :destroy, :remove_follower]


  # def create
  #   current_user.follow(@user.id)

  #   if current_user.is_following?(@user.id)
  #     Notification.create(recipient: user, action: "follow", actor: current_user)
  #   end

  #   respond_to do |format|
  #     format.html { redirect_back(fallback_location: root_path) }
  #     format.js
  #   end
  # end

  # def destroy
  #   current_user.unfollow(@user.id)

  #   respond_to do |format|
  #     format.html { redirect_back(fallback_location: root_path) }
  #     format.js { render action: :create }
  #   end
  # end

  # def remove_follower
  #   @user.remove_follower(current_user.id)

  #   respond_to do |format|
  #     format.html { redirect_back(fallback_location: root_path) }
  #     # format.js
  #   end
  # end

  # private

  # def set_user
  #   @user = User.find(params[:id])
  # end
end
