require 'open-uri'
require 'net/http'
include CloudinaryHelper

class ProductsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :show, :index, :comments, :photos ]
  before_action :set_product, only: [:show, :edit, :update, :destroy, :comments, :bookmark, :unbookmark]

  def index
    @user_bookmarks = []
    @page = params[:page] || 1
    @products = Product.page @page

    if current_user
      @user_bookmarks = Bookmark.where(user_id: current_user.id).pluck(:product_id)
    end




  end


  def show
    @user_bookmarks = []

    if current_user
      @user_bookmarks = Bookmark.where(user_id: current_user.id).pluck(:product_id)
    end


    unless @product.viewable_by?(current_user)
      flash[:alert] = "You do not have permission to view this product."
      redirect_to no_permission_path # or wherever you want
    else
      @suggested_products = Product.viewable_by(current_user).order("RANDOM()").limit(1)
    end
    @source = params[:source]
  end


  def new
    original_product = Product.find(params[:original_product_id]) if params[:original_product_id]
    @product = initialize_product_from_original(original_product) ||
               initialize_product_from_session ||
               initialize_product_from_params ||
               Product.new
    @product.subscription_type ||= 'one_time' if @product.new_record?

    @user = current_user

    # For the id to be passed to the create action so the duplication count can be incremented for the original product
    original_product_id = params[:original_product_id]
    session[:original_product_id] = original_product_id if original_product_id.present?

  end

  def create
    @product = Product.new(product_params)
    @product.price_cents = (product_params[:price].to_f * 100).round


    # For counting the duplications of a product
    puts "OG ID MAN#{session[:original_product_id]}"
    original_product_id = session.delete(:original_product_id)
    if original_product_id.present?
      original_product = Product.find(original_product_id)
      original_product.increment!(:duplicated_count)
    end


    # puts "Params: #{params.inspect}" # Added this line
    # puts "Product Params: #{product_params.inspect}" # Added this line
    # puts "Checking original product ID..."
    # if params[:original_product_id]
    #   puts "Original product ID is present."
    #   original_product = Product.find_by(id: params[:original_product_id])
    #   if original_product
    #     puts "Found original product."
    #     puts "Before increment: #{original_product.duplicated_count}"
    #     original_product.increment!(:duplicated_count) # for the counting of the number of times a product has been duplicated
    #     puts "After increment: #{original_product.duplicated_count}"
    #   else
    #     puts "No product found with ID #{params[:original_product_id]}"
    #   end
    # else
    #   puts "Original product ID is not present."
    # end
    # if params[:original_product_id]
    #   original_product = Product.find(params[:original_product_id])
    #   puts "IN THE PHOTO ADD SECTION NOW"
    #   puts "Original product: #{original_product.inspect}"
    #   if original_product.logo.attached?
    #     puts "Original product has a logo attached."
    #     new_blob = ActiveStorage::Blob.create_after_upload!(
    #       io: StringIO.new(original_product.logo.download),
    #       filename: original_product.logo.filename,
    #       content_type: original_product.logo.content_type
    #     )
    #     @product.logo.attach(new_blob.signed_id)
    #     puts "Logo has been attached to new product."
    #   end
    #   if original_product.photos.attached?
    #     puts "Original product has photos attached."
    #     original_product.photos.each do |photo|
    #       new_blob = ActiveStorage::Blob.create_after_upload!(
    #         io: StringIO.new(photo.download),
    #         filename: photo.filename,
    #         content_type: photo.content_type
    #       )
    #       @product.photos.attach(new_blob.signed_id)
    #     end
    #   end
    # else
    #   puts "PHOTOS SECTION NO ORGINIAL PRODUCT ID"
    # end

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
      trigger_list_update

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
    @source = params[:source]
  end

  def search_or_manual_product_upload
    render 'search_or_manual_product_upload'
  end


  def photos

    photo_urls = [
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688810826/Favolist%204.0/app%20assets/new_session_background/Four_Sigmatic_d05vjh_tkydzp.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688810778/Favolist%204.0/app%20assets/new_session_background/apple_vision_pro_rgcilp.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688863526/Favolist%204.0/app%20assets/new_session_background/fszap8ks4jrgqagfmzgt.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688881241/Favolist%204.0/app%20assets/new_session_background/koqymexprgvfzmxspvja.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688810825/Favolist%204.0/app%20assets/new_session_background/Whole_Bean_Coffee_Blends_owgttm_stmzhq.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688810825/Favolist%204.0/app%20assets/new_session_background/Plant_Protein-4_rxlltf_qzv5ln.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688864138/Favolist%204.0/app%20assets/new_session_background/lzazjobgpfbpa5rn3efg.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688810825/Favolist%204.0/app%20assets/new_session_background/Pique_gccbue_apxmx9.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688864598/Favolist%204.0/app%20assets/new_session_background/j2mwgfpynn6spcskdle4.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688810825/Favolist%204.0/app%20assets/new_session_background/Athletic_Greens_jhsubj_utsaj3.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688880159/Favolist%204.0/app%20assets/new_session_background/v1zqmwwfbasei9euaife.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688862938/Favolist%204.0/app%20assets/new_session_background/irwedtml33rbry2ebxco.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688810824/Favolist%204.0/app%20assets/new_session_background/Beet_Root_Powder-1_ves4cs_y6tt5i.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688862413/Favolist%204.0/app%20assets/new_session_background/peloton_row_mevppu.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688810811/Favolist%204.0/app%20assets/new_session_background/image_11_zpxtzj.png',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688810810/Favolist%204.0/app%20assets/new_session_background/image_3_sqrl6p.png',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688810798/Favolist%204.0/app%20assets/new_session_background/waffle-towel-cotton-charcoal-000-2_xr4cch.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688810797/Favolist%204.0/app%20assets/new_session_background/Theragun-PRO-Carousel-06_yzl8dc.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688810797/Favolist%204.0/app%20assets/new_session_background/pic-5_c2b5ab76-7716-4743-bca9-94aa7fd6d744_1220x1220_crop_center.jpg_liorog.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688810798/Favolist%204.0/app%20assets/new_session_background/VW459FIG_2_1200x_crop_center.jpg_aba2at.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688810797/Favolist%204.0/app%20assets/new_session_background/HJMTouryelectricbikedetail-2_h2rmm4.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688810797/Favolist%204.0/app%20assets/new_session_background/pym_pjgwba.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688810797/Favolist%204.0/app%20assets/new_session_background/Theragun-PRO-Carousel-03_io3zhk.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688810797/Favolist%204.0/app%20assets/new_session_background/MS_VARIETY_4PACK-434857_vqasda.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688810796/Favolist%204.0/app%20assets/new_session_background/apple_air_tag_jqyl0t.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688810796/Favolist%204.0/app%20assets/new_session_background/dyson-stick-vacuums-394430-01-c3_600_zl0zd3.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688810796/Favolist%204.0/app%20assets/new_session_background/download_pqtcs9.png',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688867686/Favolist%204.0/app%20assets/new_session_background/diebgusiv4g04lyqy0le.webp',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688810796/Favolist%204.0/app%20assets/new_session_background/CZ2307511-bs__39559_tcrcki.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688810796/Favolist%204.0/app%20assets/new_session_background/0730852149519_2_zwfkmy.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688810796/Favolist%204.0/app%20assets/new_session_background/cq5dam.web.320.320_ypesft.png',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688881883/Favolist%204.0/app%20assets/new_session_background/kz33tkozn6zlmfvyvu8i.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688810796/Favolist%204.0/app%20assets/new_session_background/342009_02_ajp6mx.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688810795/Favolist%204.0/app%20assets/new_session_background/666a1497-7321-41a2-acb7-dacaf35df29e_bdripa.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688810795/Favolist%204.0/app%20assets/new_session_background/5-8-cbc-sushi-foam-surfboard-foam-surfboard-7-keeper-sports-28415030034617_grande_olxln6.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688810795/Favolist%204.0/app%20assets/new_session_background/2500_3500Bundle_1_1300x_xzrlqd.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688810795/Favolist%204.0/app%20assets/new_session_background/61r6_ihVAKL._AC_UL1000__cbb6hs.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688810797/Favolist%204.0/app%20assets/new_session_background/manta_ovtjyy.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688810795/Favolist%204.0/app%20assets/new_session_background/1_ygczms.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688810778/Favolist%204.0/app%20assets/new_session_background/oura-ring-gen-3-thumb-Small-e1643052117213_c628zw.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688810778/Favolist%204.0/app%20assets/new_session_background/hydroponic_wklvzh.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688810778/Favolist%204.0/app%20assets/new_session_background/apple_vision_pro_l5jjlw.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688810778/Favolist%204.0/app%20assets/new_session_background/metaquest_b7oamk.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688810825/Favolist%204.0/app%20assets/new_session_background/LMNT-2_ymarr5_ylpuqi.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688810777/Favolist%204.0/app%20assets/new_session_background/apple_pro_display_krxggb.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688810777/Favolist%204.0/app%20assets/new_session_background/babolat-air-viper-2023_hdkydg.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688867983/Favolist%204.0/app%20assets/new_session_background/b44ot2504q7ye1ntornt.png',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688868387/Favolist%204.0/app%20assets/new_session_background/jisqnj99d3wjhvfgkpks.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688869102/Favolist%204.0/app%20assets/new_session_background/vou4k6vpdv5jpxeelymw.webp',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688869881/Favolist%204.0/app%20assets/new_session_background/p1w0l5eumjr50sbpxfwj.png',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688882676/Favolist%204.0/app%20assets/new_session_background/uabpw8od9wk0k43ptq3z.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688882676/Favolist%204.0/app%20assets/new_session_background/wyk8op6nyp09vspeehjh.jpg',
      'https://res.cloudinary.com/dncij7vr6/image/upload/v1688882676/Favolist%204.0/app%20assets/new_session_background/cgosnegwxhdafcuunww2.jpg',
  ]




    # Slice the array into chunks to simulate rows
    rows = photo_urls.each_slice((photo_urls.size / 4.0).ceil).to_a

    # Render the rows as JSON
    render json: rows
  end


  private

  def product_params
    params.require(:product).permit(:title, :price, :price_cents, :price_currency, :subscription_type, :review, :description, :url, :list_id, :currency, :logo, photos: [], referral_attributes: [:id, :code, :details])
  end

  def set_product
    @product = Product.find(params[:id])
  end


def trigger_list_update
  if @product.list.present?
    Rails.logger.info "Triggering list update for List ID: #{@product.list.id}"
    @product.list.regenerate_background
  end
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
    puts "Session product data::: #{product_data}"

    user_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    headers = {
      "User-Agent" => user_agent,
      "Referer" => product_data[:url] # Adding the Referer header
    }


    # Handle logo processing
    if product_data[:logo]
      logo_url = product_data[:logo]
      begin
        downloaded_logo = URI.open(logo_url, headers) # to also be able to download images with scrape restrictions

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
      rescue OpenURI::HTTPError => e
        Rails.logger.error "Failed to download the logo from #{logo_url}: #{e.message}"
        # Keep a default logo as a fallback or just skip setting the logo
        @logo = ActiveStorage::Blob.find_by(filename: 'amazon_logo.png')
      end
    elsif product_data[:source] == "amazon"
      @logo = ActiveStorage::Blob.find_by(filename: 'amazon_logo.png')
    elsif product_data[:source] == "tokopedia"
      @logo = ActiveStorage::Blob.find_by(filename: 'tokopedia_logo.png')
    end

    # Handle images processing
    @photos = product_data[:images].map do |image_url|
      begin
        downloaded_image = URI.open(image_url,  headers) # to also be able to download images with scrape restrictions
        blob = ActiveStorage::Blob.create_and_upload!(
          io: downloaded_image,
          filename: File.basename(image_url),
          content_type: downloaded_image.content_type
        )
        blob
      rescue OpenURI::HTTPError => e
        Rails.logger.error "Failed to download image from #{image_url}: #{e.message}"
        nil # return nil so that we can filter it out later
      end
    end.compact # Remove nil values

    Product.new(
      title: product_data[:title],
      price: product_data[:price],
      description: product_data[:description],
      url: product_data[:url],
      price_currency: product_data[:currency]
    ).tap do |product|
      product.photos.attach(@photos)
      session.delete(:product_data)
    end
  end


  def initialize_product_from_params
    return unless params[:product]

    Product.new(product_params)
    session.delete(:product_data)
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
