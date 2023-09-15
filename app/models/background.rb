class Background < ApplicationRecord
  belongs_to :list

  # This creates the necessary association for ActiveStorage with Cloudinary
  has_one_attached :image
end
