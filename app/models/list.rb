require 'uri'
include CloudinaryHelper


class List < ApplicationRecord

  include PgSearch::Model

  has_one_attached :background_image, dependent: :destroy

  after_commit :regenerate_background, if: -> { saved_change_to_products_count? }

  belongs_to :user
  has_many :products, dependent: :destroy
  has_many :referrals, through: :products

  pg_search_scope :search_by_name_and_description_and_product_title_and_user_username,
  against: [:name, :description],
  associated_against: {
    products: [:title],
    user: [:username]
  },
  using: {
      tsearch: { prefix: true }
  }

  # Define the viewable_by scope
  scope :viewable_by, -> (user) {
    joins(:user).where(users: { id: User.viewable_by(user).pluck(:id) })
  }

  # Define the viewable_by? method
  def viewable_by?(user)
    User.viewable_by(user).include?(self.user)
  end

  def regenerate_background
    puts "Regenerating background for List: #{id}"
    new_image = generate_background_image
    puts "Generated Image: #{new_image.inspect}"

    return unless new_image

    # Convert the RMagick image to a Cloudinary-friendly format
    file = StringIO.new(new_image.to_blob)
    # Upload directly to Cloudinary
    uploaded_image = Cloudinary::Uploader.upload(file, public_id: "list_backgrounds/#{id}")
    # Attach the Cloudinary URL to the List instance via Active Storage
    background_image.attach(io: URI.open(uploaded_image['url']), filename: "list_background_#{id}.jpg")
  end


  def generate_background_image
    begin
      img_list = Magick::ImageList.new
      products_with_photos = products.select { |p| p.photos.attached? }
      grid_size = determine_grid_size(products_with_photos.count)

      # Prepare the photos
      photos_for_grid = prepare_photos_for_grid(products_with_photos, grid_size)

      photos_for_grid.each do |photo|
        if photo
          cloudinary_base = "https://res.cloudinary.com/dncij7vr6/image/upload"
          cloudinary_path = "v1/development"
          cloudinary_transformations = "c_fill,h_100,w_100"

          # Construct the new Cloudinary URL
          cloudinary_url = "#{cloudinary_base}/#{cloudinary_transformations}/#{cloudinary_path}/#{photo.key}"


          img_data = Net::HTTP.get(URI.parse(cloudinary_url))

          if img_data.empty?
            Rails.logger.error "Failed to retrieve image data from Cloudinary for URL: #{cloudinary_url}"
            img_list << Magick::Image.new(100, 100) { background_color = 'gray' }
            next
          end

          img = Magick::Image.from_blob(img_data).first
          img_list << img
        else
          img_list << Magick::Image.new(100, 100) { |img| img.background_color = 'gray' }
        end
      end

      combined_image = nil

      # Join the images into a grid
      # Join the images into a grid
      case grid_size
      when 1
        combined_image = img_list.first
      when 4
        combined_image = img_list.montage do |montage|
          montage.geometry = '100x100+0+0'
          montage.tile = '2x2'
        end.first # extract the image from the ImageList
      when 9
        combined_image = img_list.montage do |montage|
          montage.geometry = '100x100+0+0'
          montage.tile = '3x3'
        end.first
      when 16
        combined_image = img_list.montage do |montage|
          montage.geometry = '100x100+0+0'
          montage.tile = '4x4'
        end.first # extract the image from the ImageList
      end

      puts "Combined Image Type: #{combined_image.class}"
      puts "Combined Image Value: #{combined_image.inspect}"


      combined_image.format = 'JPEG'

      combined_image # Return the final combined image

    rescue Magick::ImageMagickError => e
      Rails.logger.error "RMagick error: #{e.message}"
      # Handle the error appropriately, maybe return a default image or nil
      return nil
    end
  end


  private

  def determine_grid_size(count)
    case count
    when 1..3 then 1
    when 4..8 then 4
    when 9..15 then 9
    else 16
    end
  end

  def prepare_photos_for_grid(products_with_photos, grid_size)
    photos = products_with_photos.map { |p| p.photos.first }
    while photos.count < grid_size
      photos << nil
    end
    photos.first(grid_size)
  end

  def ensure_background_exists
    build_background unless background
  end

end
