require 'open-uri'
require 'net/http'
include CloudinaryHelper

class ProductsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :show, :index, :comments ]
  before_action :set_product, only: [:show, :edit, :update, :destroy, :comments, :bookmark, :unbookmark]

  def index
    @products = Product.viewable_by(current_user)
  end


  def show
    unless @product.viewable_by?(current_user)
      flash[:alert] = "You do not have permission to view this product."
      redirect_to no_permission_path # or wherever you want
    else
      @suggested_products = Product.viewable_by(current_user).joins(list: :user)
                                   .order("users.followers_count DESC")
                                   .limit(2)
    end
  end


  def new
    original_product = Product.find(params[:original_product_id]) if params[:original_product_id]
    @product = initialize_product_from_original(original_product) ||
               initialize_product_from_session ||
               initialize_product_from_params ||
               Product.new
    @user = current_user
  end

  def create
    @product = Product.new(product_params)

    if params[:original_product_id]
      original_product = Product.find(params[:original_product_id])
      if original_product.logo.attached?
        new_blob = ActiveStorage::Blob.create_after_upload!(
          io: StringIO.new(original_product.logo.download),
          filename: original_product.logo.filename,
          content_type: original_product.logo.content_type
        )
        @product.logo.attach(new_blob.signed_id)
      end

      if original_product.photos.attached?
        original_product.photos.each do |photo|
          new_blob = ActiveStorage::Blob.create_after_upload!(
            io: StringIO.new(photo.download),
            filename: photo.filename,
            content_type: photo.content_type
          )
          @product.photos.attach(new_blob.signed_id)
        end
      end
    end

    if @product.save
      if params[:product][:logo].present?
        @product.logo.attach(params[:product][:logo])
      end

      if params[:product][:photos]
        params[:product][:photos].reject(&:blank?).reverse.each do |photo_blob_id|
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
    render :edit
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

  def search_or_manual_product_upload
    render 'search_or_manual_product_upload'
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

  def initialize_product_from_original(original_product)
    return unless original_product

    @logo = original_product.logo if original_product.logo.attached?
    @photos = original_product.photos if original_product.photos.attached?

    Product.new(
      title: original_product.title,
      price: original_product.price,
      description: original_product.description,
      url: original_product.url
    )
  end

  def initialize_product_from_session
    return unless session[:product_data]

    product_data = session[:product_data]

    if product_data['logo']
      logo_url = product_data['logo']
      downloaded_logo = URI.open(logo_url)
      filename = File.basename(logo_url)

      if filename.ends_with?('.svg')
        uploaded_image = Cloudinary::Uploader.upload(logo_url)
        png_url = Cloudinary::Utils.cloudinary_url(uploaded_image["public_id"], format: "png")
        downloaded_logo = URI.open(png_url)
        filename = filename.gsub('.svg', '.png')
      end

      @logo = ActiveStorage::Blob.create_and_upload!(
        io: downloaded_logo,
        filename: filename,
        content_type: downloaded_logo.content_type
      )
    else
      @logo = ActiveStorage::Blob.find_by(filename: 'amazon_logo.png')
    end

    @photos = product_data['images'].map do |image_url|
      downloaded_image = URI.open(image_url)
      blob = ActiveStorage::Blob.create_and_upload!(
        io: downloaded_image,
        filename: File.basename(image_url),
        content_type: downloaded_image.content_type
      )
      blob
    end

    Product.new(
      title: product_data['title'],
      price: product_data['price'],
      description: product_data['description'],
      url: product_data['url']
    ).tap do |product|
      product.photos.attach(@photos)
      session.delete(:product_data)
    end
  end

  def initialize_product_from_params
    return unless params[:product]

    Product.new(product_params)
  end
end





# -----------------------------------------------------------------------------------------------------------------------
# fetch_amazon_product:
# This method is responsible for fetching product data from the Amazon product API. It constructs a URL with the passed in ASIN (Amazon Standard Identification Number) and sends a GET request to this URL. The API's response is expected to be a JSON containing details about the product.

# The response body is parsed into a Ruby hash, and the required details like title, price, description, and images are extracted from it. These details are then stored in the session under the :product_data key. This is done so that the data can be used in the new action to pre-fill the form fields. If the product data is not present, it redirects the user back to the search or manual upload page and displays an error message.

# new:
# This method is responsible for initializing a new product for creation. It handles different cases based on where the data for the new product is coming from.

# If the product is being duplicated from an existing product (original_product), it initializes a new product with the details of the original product. The logo and photos from the original product are also assigned to instance variables @logo and @photos if they exist, which can be used in the view to display these attachments.
# If the product data is present in the session (which means it was fetched from Amazon), it initializes a new product with this data. It also downloads the images from the fetched data, creates new ActiveStorage blobs from these images, and assigns these blobs to @photos. The logo is fetched from a previously stored blob with filename 'amazon_logo.png'. These blobs can later be attached to the product in the create action.
# If neither of the above conditions are met, it simply initializes a new empty product.

# create:
# This method attempts to create and save a new product from the form data. If the product is a duplicate, it downloads the logo and photos from the original product, creates new blobs from these downloads, and attaches these blobs to the new product. This is done to ensure that each product has its own copies of the attachments and changes to the original product's attachments do not affect the duplicate product.

# If the logo or photos are included in the form data (which could be the case if the product data was fetched from Amazon), these blobs are attached to the product.

# If the product is saved successfully, the user is redirected to the new product's page with a success message. If not, the form is re-rendered with error messages.

# The logic in these methods takes into account different scenarios to ensure that the attachments (logo and photos) are handled properly based on where the product data is coming from. The use of ActiveStorage blobs makes it possible to handle file uploads in a consistent way across these different scenarios.
