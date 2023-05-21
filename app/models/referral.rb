class Referral < ApplicationRecord
  include PgSearch::Model

  belongs_to :product

  validates :code, presence: true
  validates :details, presence: true

  def user_username
    self.product.list.user.username
  end

  def list_name
    self.product.list.name
  end

  pg_search_scope :search_by_user_and_list,
  against: [:code, :details],
  associated_against: {
    product: [:title, :description, { list: [:name, { user: :username }] }]
  },
  using: {
    tsearch: { prefix: true }
  }


end
