class Referral < ApplicationRecord
  include PgSearch::Model

  belongs_to :product

  validates :code, presence: true
  validates :details, presence: true

  pg_search_scope :search_by_product_title_description_list_name_and_user_username,
  associated_against: {
    product: [:title, :description, :user_username, { list: :name }]
  },
  using: {
    tsearch: { prefix: true }
  }
end
