class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy, :comments]

  def index
    @products = Product.all
  end

  def show
  end

  def new
    @product  = Product.new
    @user = current_user
  end

  def create
    @product = Product.new(product_params)
    @product.logo.attach(params[:product][:logo])
    @product.photos.attach(params[:product][:photos])
    if @product.save
      redirect_to list_path(@product.list)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_to list_path(@product.list), notice: 'Product was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    if @product.destroy
      redirect_to list_path(@product.list), notice: 'Product was successfully destroyed.'
    else
      redirect_to list_path(@product.list), notice: 'Product was not destroyed.'
    end
  end


  def comments
  end

  def bookmark
    bookmark = Bookmark.new(user: current_user, product: @product)
    if bookmark.save
      render json: { action: "bookmark", unbookmark_path: unbookmark_product_path(@product) }
    else
      head :unprocessable_entity
    end
  end

  def unbookmark
    bookmark = Bookmark.find_by(user: current_user, product: @product)
    if bookmark.destroy
      render json: { action: "unbookmark", bookmark_path: bookmark_product_path(@product) }
    else
      head :unprocessable_entity
    end
  end


  private

  def product_params
    params.require(:product).permit(:title, :price, :review, :description, :url, :list_id)
  end

  def set_product
    @product = Product.find(params[:id])
  end
end
