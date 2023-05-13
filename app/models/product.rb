class Product < ApplicationRecord
  belongs_to :list
  has_one :user, through: :list
  has_many_attached :photos
  has_one_attached :logo
end
