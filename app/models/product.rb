class Product < ApplicationRecord
  include PgSearch::Model

  belongs_to :list
  has_one :user, through: :list
  has_many :referrals, dependent: :destroy
  has_many_attached :photos
  has_one_attached :logo

  pg_search_scope :search_by_title_and_description_and_list_name_and_user_username,
  against: [:title, :description, :user_username],
  associated_against: {
    list: [:name]
  },
  using: {
    tsearch: { prefix: true }
  }

  #this is for the pg_search to work on the referral model (see referral.rb) so I can search referral by username, since its not directly associated with the product
  def user_username
    self.user.try(:username)
  end
end
