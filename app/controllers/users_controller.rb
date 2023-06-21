class UsersController < ApplicationController
  before_action :set_user, only: [:show, :follow, :unfollow, :follows, :remove_follower, :bookmark, :unbookmark]

  def index
    @users = User.all
  end

  def follow
    if current_user.follow(@user.id)
      respond_to do |format|
        format.html { redirect_back(fallback_location: root_path) }
        format.js
      end
    end
  end

  def unfollow
    if current_user.unfollow(@user.id)
      respond_to do |format|
        format.html { redirect_back(fallback_location: root_path) }
        format.js { render action: :follow }
      end
    end
  end

  def remove_follower
    if current_user.remove_follower(@user.id)
      respond_to do |format|
        format.html { redirect_back(fallback_location: root_path) }
        format.js
      end
    end
  end

  def show
    @lists = @user.lists
    @referrals = @user.products.flat_map(&:referrals)
    @suggested_users = @user.followed.order(followers_count: :desc).sample(2)
    @suggested_lists = List.where(user: @user.followed).order(products_count: :desc).limit(2)
  end

  def follows
    @followers = @user.followers
    @followed = @user.followed
  end


  def bookmark
    if current_user.bookmark(params[:product_id])
      respond_to do |format|
        format.html { redirect_back(fallback_location: root_path) }
        format.js
      end
    end
  end

  def unbookmark
    if current_user.unbookmark(params[:product_id])
      respond_to do |format|
        format.html { redirect_back(fallback_location: root_path) }
        format.js { render action: :bookmark }
      end
    end
  end



  private

  def set_user
    @user = User.find(params[:id])
  end
end
