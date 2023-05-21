class List < ApplicationRecord
  include PgSearch::Model

  belongs_to :user
  has_many :products, dependent: :destroy

  pg_search_scope :search_by_name_and_description_and_product_title_and_user_username,
  against: [:name, :description],
  associated_against: {
    products: [:title],
    user: [:username]
  },
  using: {
      tsearch: { prefix: true }
  }

end
