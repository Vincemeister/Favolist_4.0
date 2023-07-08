require 'open-uri'
require 'net/http'
include CloudinaryHelper

class ProductsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :show, :index, :comments, :photos ]
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

    puts "@product: #{ @product.inspect }"
    puts "@product.referral: #{ @product.referral.inspect }"

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
      if params[:product][:referral_attributes][:code] == "" && params[:product][:referral_attributes][:details] == ""
        @product.referral.destroy
      end

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
    @logo = @product.logo if @product.logo.attached?
    @photos = @product.photos if @product.photos.attached?
    @referral = @product.referral if @product.referral
    render :edit
  end

  def update
    if @product.update(product_params)
      if params[:product][:referral_attributes][:code] == "" && params[:product][:referral_attributes][:details] == ""
        @product.referral.destroy
      end
      redirect_to product_path(@product), notice: 'Product was successfully updated.'
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


  def photos

    photo_urls = ['https://res.cloudinary.com/dncij7vr6/image/upload/v1688718050/Favolist%204.0/app%20assets/new_session_background/HJMTouryelectricbikedetail-2_ecpjm5.webp',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688718049/Favolist%204.0/app%20assets/new_session_background/MS_VARIETY_4PACK-434857_wfkgme.avif',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688718049/Favolist%204.0/app%20assets/new_session_background/apple_air_tag_fvhz4f.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688718049/Favolist%204.0/app%20assets/new_session_background/pic-5_c2b5ab76-7716-4743-bca9-94aa7fd6d744_1220x1220_crop_center.jpg_jpyxbl.webp',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688718049/Favolist%204.0/app%20assets/new_session_background/cybertruck-tesla-elon-musk-steel-electric-vehicle-car-truck-_dezeen_2364_sq-300x300_tjn9kz.webp',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688718048/Favolist%204.0/app%20assets/new_session_background/666a1497-7321-41a2-acb7-dacaf35df29e_bblue1.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688718048/Favolist%204.0/app%20assets/new_session_background/Theragun-PRO-Carousel-06_gwrzgh.webp',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688718047/Favolist%204.0/app%20assets/new_session_background/0730852149519_2_huplqo.webp',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688718047/Favolist%204.0/app%20assets/new_session_background/5-8-cbc-sushi-foam-surfboard-foam-surfboard-7-keeper-sports-28415030034617_grande_rjusdg.webp',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688717656/Favolist%204.0/app%20assets/new_session_background/Whole_Bean_Coffee_Blends_owgttm_mdtrsx.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688717655/Favolist%204.0/app%20assets/new_session_background/Beet_Root_Powder-1_ves4cs_vudmd6.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688717654/Favolist%204.0/app%20assets/new_session_background/Plant_Protein-4_rxlltf_ygwixf.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688717654/Favolist%204.0/app%20assets/new_session_background/Macadamia_Nuts-2_aybt98_ikcwm7.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688717612/Favolist%204.0/app%20assets/new_session_background/image_3_kvhegd.png',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688717612/Favolist%204.0/app%20assets/new_session_background/b4bdf9f6-0a42-40c9-8931-05582090db48_1_r1zhxo.png',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688717612/Favolist%204.0/app%20assets/new_session_background/image_11_cs1hgo.png',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688717611/Favolist%204.0/app%20assets/new_session_background/image_4_zczom4.png',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688717654/Favolist%204.0/app%20assets/new_session_background/Plant_Protein-4_rxlltf_ygwixf.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688717654/Favolist%204.0/app%20assets/new_session_background/AeroPresss_rbagzs.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688717654/Favolist%204.0/app%20assets/new_session_background/Macadamia_Nuts-2_aybt98_ikcwm7.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688718047/Favolist%204.0/app%20assets/new_session_background/61r6_ihVAKL._AC_UL1000__q9lwbl.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688718048/Favolist%204.0/app%20assets/new_session_background/Theragun-PRO-Carousel-03_o2datd.webp',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688718049/Favolist%204.0/app%20assets/new_session_background/pym_cgmj0d.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688717654/Favolist%204.0/app%20assets/new_session_background/Four_Sigmatic_d05vjh_qqjuk6.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688717612/Favolist%204.0/app%20assets/new_session_background/image_3_kvhegd.png',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688717654/Favolist%204.0/app%20assets/new_session_background/AeroPresss_rbagzs.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688718051/Favolist%204.0/app%20assets/new_session_background/9735ca4df2851fb084a1fae7ec09deebf391e45c-2560x2560_thssbz.webp',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688790056/Favolist%204.0/app%20assets/new_session_background/hydroponic_o2vfyg.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688790055/Favolist%204.0/app%20assets/new_session_background/madcatz-r.a.t.-8--16000-dpi-gaming-mouse_j5fhk8.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688790055/Favolist%204.0/app%20assets/new_session_background/apple_pro_display_eprjtg.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688790054/Favolist%204.0/app%20assets/new_session_background/oura-ring-gen-3-thumb-Small-e1643052117213_mty0ja.webp',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688790054/Favolist%204.0/app%20assets/new_session_background/babolat-air-viper-2023_hbjnzr.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688790054/Favolist%204.0/app%20assets/new_session_background/apple_vision_pro_sryrql.webp',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688790055/Favolist%204.0/app%20assets/new_session_background/drone_combo_vahxvr.jpg'

  ]
    # Slice the array into chunks to simulate rows
    rows = photo_urls.each_slice((photo_urls.size / 4.0).ceil).to_a

    # Render the rows as JSON
    render json: rows
  end


  private

  def product_params
    params.require(:product).permit(:title, :price, :review, :description, :url, :list_id, :logo, photos: [], referral_attributes: [:id, :code, :details])
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

    new_product = Product.new(
      title: original_product.title,
      price: original_product.price,
      description: original_product.description,
      url: original_product.url
    )

    if original_product.referral
      new_product.build_referral(
        code: original_product.referral.code,
        details: original_product.referral.details
      )
    end

    new_product

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
