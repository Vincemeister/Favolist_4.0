class Referral < ApplicationRecord

  scope :viewable_by, -> (user) {
    joins(product: { list: :user }).where(users: { id: User.viewable_by(user).pluck(:id) })
  }


  include PgSearch::Model

  belongs_to :product

  # validates :code, presence: true
  # validates :details, presence: true


  def product_user_username
    product.user.username if product && product.user
  end

  def product_list_name
    product.list.name if product && product.list
  end

  # then define your search scope
  def self.search_by_product_title_user_username_and_list_name(query)
    search_term = "%#{query}%"
    joins(product: { list: :user })
      .where(
        "referrals.code ILIKE :search
        OR referrals.details ILIKE :search
        OR products.title ILIKE :search
        OR users.username ILIKE :search
        OR lists.name ILIKE :search",
        { search: search_term }
      )
  end

  def viewable_by?(user)
    User.viewable_by(user).include?(self.product.list.user)
  end

end
