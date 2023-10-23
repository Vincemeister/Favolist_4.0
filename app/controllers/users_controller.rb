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
    if current_user
      @user_bookmarks = Bookmark.where(user_id: current_user.id).pluck(:product_id)
      @suggested_users = (User.where.not(id: current_user.id).where(is_creator: true) - current_user.followed).sample(1)
    else
      @user_bookmarks = []
      @suggested_users = User.all.where(is_creator: true).sample(1)
    end


    @products_count = @user.products.count
    @lists_count = @user.lists.count
    @referrals_count = @user.referrals.count
    @user_bookmarks = []

    @type = params[:type] || "product"  # default to product if no type is given
    @pagination_url = user_url(@user)
    @product_page = params[:page] || 1
    @list_page = params[:page] || 1
    @referral_page = params[:page] || 1


    case @type
    when "product"
      @products = @user.products.includes(:list, photos_attachments: :blob, user: [{avatar_attachment: :blob}])
                        .page(@product_page)
    when "list"
      @lists = @user.lists
                   .includes(:user, background_image_attachment: :blob)
                   .page(@list_page)
    when "referral"
      @referrals = @user.referrals.page(@referral_page)
    end



    respond_to do |format|
      format.html
      format.json
      format.turbo_stream
    end
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
