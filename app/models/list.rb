class List < ApplicationRecord
  include PgSearch::Model

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


end
