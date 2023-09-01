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
      @products = @list.products.includes(:referral, photos_attachments: :blob, user: [{avatar_attachment: :blob}])
      @referrals = @list.products.flat_map(&:referral).compact
      @user_bookmarks = []

      if current_user
        @user_bookmarks = Bookmark.where(user_id: current_user.id).pluck(:product_id)
      end

      @suggested_lists = List.viewable_by(current_user).order("RANDOM()").limit(1).to_a
      # @suggested_products = Product.viewable_by(current_user).order("RANDOM()").limit(1)
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
      redirect_to list_path(@list)
    else
      render :new
    end
  end

  def edit
  end

  def update
    @list.update(list_params)
    redirect_to list_path(@list)
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
    params.require(:list).permit(:name, :description)
  end

  def set_list
    @list = List.includes(:products, :user).find(params[:id])
  end
end
