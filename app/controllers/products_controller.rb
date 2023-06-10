class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy, :comments, :bookmark, :unbookmark]

  def index
    @products = Product.all
  end

  def show
  end

  def new
    original_product = Product.find(params[:original_product_id]) if params[:original_product_id]
    @product = if original_product
      @photos = original_product.photos if original_product.photos.attached?
      Product.new(
        title: original_product.title,
        price: original_product.price,
        description: original_product.description
      )
    else
      Product.new
    end
    @user = current_user
  end

  def create
    @product = Product.new(product_params)

    if params[:original_product_id]
      original_product = Product.find(params[:original_product_id])
      @product.logo.attach(original_product.logo.blob.signed_id) if original_product.logo.attached?
    else
      @product.logo.attach(params[:product][:logo]) if params[:product][:logo]
    end

    if params[:product][:photos]
      params[:product][:photos].each do |photo_blob_id|
        @product.photos.attach(photo_blob_id) unless photo_already_attached?(photo_blob_id)
      end
    end

    if @product.save
      redirect_to product_path(@product), notice: 'Product was successfully created.'
    else
      flash[:error] = @product.errors.full_messages
      redirect_to new_product_path
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


  private

  def product_params
    params.require(:product).permit(:title, :price, :review, :description, :url, :list_id, :logo, photos: [])
  end


  def set_product
    @product = Product.find(params[:id])
  end

  def photo_already_attached?(blob_id)
    @product.photos.blobs.any? { |blob| blob.signed_id == blob_id }
  end
end
