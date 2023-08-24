class Bookmark < ApplicationRecord
  belongs_to :user
  belongs_to :product, counter_cache: true

  validates :user, uniqueness: { scope: :product }
end
