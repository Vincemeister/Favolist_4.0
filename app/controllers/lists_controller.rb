require 'open-uri'

class ListsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index, :show ] 
  before_action :set_list, only: [:show, :edit, :update, :destroy, :add_product, :remove_product]

  def index
    @lists = List.viewable_by(current_user)
  end

  def show
    unless @list.viewable_by?(current_user)
      redirect_to no_permission_path
    else
      # @products = @list.products.includes(:referral, photos_attachments: :blob, user: [{avatar_attachment: :blob}])
      @products = @list.products.order(:position).includes(:referral, photos_attachments: :blob, user: [{avatar_attachment: :blob}])

      @referrals = @list.referrals.order(:position).includes(:product, product: [{photos_attachments: :blob}, {user: [{avatar_attachment: :blob}]}])

      if current_user
        @user_bookmarks = Bookmark.where(user_id: current_user.id).pluck(:product_id)
        random_list = List.joins(:user)
        .where(users: { is_creator: true })
      .merge(User.viewable_by(current_user))
      .where.not(user_id: current_user.id)
      .order("RANDOM()")
      .first
        @suggested_lists = random_list ? [random_list] : []
      else
        @user_bookmarks = []
        random_list = List.joins(:user)
        .where(users: { is_creator: true })
        .merge(User.viewable_by(nil))
        .order("RANDOM()")
        .first
        @suggested_lists = random_list ? [random_list] : []
      end
    end
    @source = params[:source]
  end


  def new
    @list = List.new
  end

  def create
    @list = List.new(list_params)
    @user = current_user
    @list.user = @user
    if @list.save
      set_default_background_if_empty
      redirect_to list_path(@list)
    else
      render :new
    end
  end

  def edit
  end

  # def update
  #   @list.update(list_params)
  #   if list_params.keys == ["position"]
  #     # If only position is updated, respond differently
  #     head :ok
  #   else
  #     redirect_to list_path(@list), notice: 'List was successfully updated.'
  #   end
  # end


  def update
    logger.info "=== Entering ListsController#update ==="

    logger.info "List Params: #{list_params.inspect}"

    update_result = @list.update(list_params)

    logger.info "Update Result: #{update_result}"
    logger.info "Errors: #{@list.errors.full_messages.to_sentence}" if @list.errors.any?

    if list_params.keys == ["position"]
      logger.info "Only updating position. Responding with head :ok"
      head :ok
    else
      logger.info "Redirecting to list path"
      redirect_to list_path(@list), notice: 'List was successfully updated.'
    end

    logger.info "=== Exiting ListsController#update ==="
  end


  def destroy
    if @list.destroy
      redirect_to user_path(current_user), notice: 'list was successfully destroyed.'
    else
      redirect_to list_path(list), notice: 'list was not destroyed.'
    end
  end
  private

  def list_params
    params.require(:list).permit(:name, :description, :position)
  end

  def set_list
    @list = List.includes(:products, :user).find(params[:id])
  end


  def set_default_background_if_empty
    unless @list.background_image.attached?
      default_image_url = "https://res.cloudinary.com/dncij7vr6/image/upload/v1687825911/Favolist%204.0/app%20assets/grey_rectangle_byagze.png"
      @list.background_image.attach(io: URI.open(default_image_url),
                                    filename: "default_background.png",
                                    content_type: "image/png")
    end
  end

end
