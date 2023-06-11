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
    elsif params[:product]
      Product.new(product_params)
    else
      Product.new
    end
    @user = current_user
  end

def create
  @product = Product.new(product_params)

  if params[:original_product_id]
    original_product = Product.find(params[:original_product_id])
    if original_product.logo.attached?
      @product.logo.attach(original_product.logo.blob.signed_id)
    end
    # If there are photos to copy, we create new blobs for each of them
    if original_product.photos.attached?
      original_product.photos.each do |photo|
        new_blob = ActiveStorage::Blob.create_after_upload!(
          io: StringIO.new(photo.download), # we download the old photo to a StringIO object
          filename: photo.filename, # we keep the old filename
          content_type: photo.content_type # we keep the old content_type
        )
        @product.photos.attach(new_blob.signed_id) # we attach the new blob to the new product
      end
    end
  else
    @product.logo.attach(params[:product][:logo]) if params[:product][:logo]
  end

  if @product.save
    if params[:product][:photos]
      params[:product][:photos].reject(&:blank?).each do |photo_blob_id|
        @product.photos.attach(photo_blob_id) unless blob_exists?(photo_blob_id)
      end
    end
    redirect_to product_path(@product), notice: 'Product was successfully created.'
  else
    flash[:error] = @product.errors.full_messages
    redirect_to new_product_path(product: product_params)
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

  def blob_exists?(blob_id)
    ActiveStorage::Blob.exists?(blob_id)
  end

end
