# gem for the fetch_amazon method
require 'open-uri'
require 'net/http'



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
      @logo = original_product.logo if original_product.logo.attached?
      @photos = original_product.photos if original_product.photos.attached?
      Product.new(
        title: original_product.title,
        price: original_product.price,
        description: original_product.description
      )
    elsif session[:product_data]
      product_data = session[:product_data]
      @photos = product_data['images'].map do |image_url|
        # Download the image from the URL
        downloaded_image = URI.open(image_url)
        # Create a new ActiveStorage blob from the downloaded image
        blob = ActiveStorage::Blob.create_and_upload!(
          io: downloaded_image,
          filename: File.basename(image_url),
          content_type: downloaded_image.content_type
        )
        blob # Return blob here instead of blob.signed_id
      end

      Product.new(
        title: product_data['title'],
        price: product_data['price'],
        description: product_data['description']
      ).tap do |product|
        product.photos.attach(@photos)
        session.delete(:product_data) # delete the session data here
      end

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
        new_blob = ActiveStorage::Blob.create_after_upload!(
          io: StringIO.new(original_product.logo.download), # we download the old photo to a StringIO object
          filename: original_product.logo.filename, # we keep the old filename
          content_type: original_product.logo.content_type # we keep the old content_type
        )
        @product.logo.attach(new_blob.signed_id) # we attach the new blob to the new product
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
    end

    if @product.save
      if params[:product][:logo].present?
        logo_blob_id = params[:product][:logo]
        @product.logo.attach(logo_blob_id) unless blob_exists?(logo_blob_id)
      end
      if params[:product][:photos]
        # adding reverse because the last image uploaded is the first one in the array
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


  def fetch_amazon_product
    product_data = fetch_product_from_amazon(params[:asin])

    if product_data.present?
      session[:product_data] = product_data
      redirect_to new_product_path
    else
      flash[:error] = 'Failed to fetch product data from Amazon.'
      redirect_to search_or_manual_product_upload_path
    end
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

  def fetch_product_from_amazon(asin)
    url = URI("https://parazun-amazon-data.p.rapidapi.com/product/?asin=#{asin}&region=US")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["X-RapidAPI-Key"] = '971b32dc4emshdc908738f2fb7c0p15bcc5jsn4f8c98db4f7d'
    request["X-RapidAPI-Host"] = 'parazun-amazon-data.p.rapidapi.com'

    response = http.request(request)
    response_body = JSON.parse(response.body) # convert the JSON response to a Ruby hash

    # Extracting the title, price, and description
    title = response_body["title"]
    price = response_body["price"]["amount"]
    description = response_body["description"].join(' ') # join array elements into a single string
    # Extract all high resolution images
    images = response_body["images"].map do |image_hash|
      image_hash["hi_res"]
    end


    puts "Title: #{title}"
    puts "Price: #{price}"
    puts "Description: #{description}"
    puts "Images: #{images}"

    # Here, you can create a new instance of Product, or return these values as a hash
    product_data = { title: title, price: price, description: description, images: images }

    puts product_data # for debugging purposes

    product_data # return the product data
  end

end
