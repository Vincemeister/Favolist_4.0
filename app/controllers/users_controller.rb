class UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :show, :index ]

  before_action :set_user, only: [:show, :test, :follow, :unfollow, :follows, :remove_follower, :bookmark, :unbookmark]

  def index
    @users = User.all
  end



  def follow
    if current_user.follow(@user.id)
      if params[:iterating_for] == "sidebar"
        flash[:notice] = "You are now following #{@user.username}"
        render json: { flash: flash, hideButton: true }
      else
        flash[:notice] = "You are now following #{@user.username}"
        render json: { flash: flash, newButtonText: "Followed", newButtonClass: "button button-secondary", newMethod: "post", newPath: unfollow_user_path(@user) }
        # render json: { flash: flash, hideButton: true }
      end
    else
      flash[:alert] = "There was a problem following #{@user.username}"
      render json: { flash: flash }, status: :unprocessable_entity
    end
  end


  def unfollow

    if current_user.unfollow(@user.id)
      flash[:notice] = "You are not following #{@user.username} anymore"
      render json: { flash: flash, newButtonText: "Follow", newButtonClass: "button button-primary", newMethod: "post", newPath: follow_user_path(@user) }
    else
      flash[:alert] = "There was a problem unfollowing #{@user.username}"
      render json: { flash: flash }, status: :unprocessable_entity
    end


    # if current_user.unfollow(@user.id)
    #   respond_to do |format|
    #     format.html { redirect_back(fallback_location: root_path) }
    #     format.js { render action: :follow }
    #   end
    # end
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

    
    @pagination_url = search_url
    @page = params[:page] || 1

    @products = @user.products
    @products = @user.products.includes(:list, photos_attachments: :blob, user: [{avatar_attachment: :blob}]).page(@page)


    @user_bookmarks = []

    if current_user
      @user_bookmarks = Bookmark.where(user_id: current_user.id).pluck(:product_id)
    end


    @lists = @user.lists
    @referrals = @user.products.flat_map(&:referral).compact
    if current_user
      # @user = current_user
      @suggested_users = User.all - current_user.followed
      @suggested_users = @suggested_users.sample(1)
    else
      @suggested_users = User.all.sample(1)
    end
    # random_list = List.viewable_by(current_user).order("RANDOM()").first
    # @suggested_lists = [random_list] if random_list
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
    @user = User.includes(avatar_attachment: :blob, products: [{photos_attachments: :blob}, :referral, :user, :list]).find(params[:id])
  end
end
