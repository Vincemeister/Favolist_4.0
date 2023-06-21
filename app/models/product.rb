class Product < ApplicationRecord
  include PgSearch::Model

  belongs_to :list, optional: true, counter_cache: true
  has_one :user, through: :list
  has_many :referrals, dependent: :destroy
  has_many :comments, dependent: :destroy

  has_one_attached :logo, dependent: :destroy
  has_many_attached :photos, dependent: :destroy

  has_many :bookmarks, dependent: :destroy
  has_many :bookmarked_by, through: :bookmarks, source: :user



  pg_search_scope :search_by_title_and_description_and_list_name_and_user_username,
  against: [:title, :description],
  associated_against: {
      list: [:name],
      user: [:username]
  },
  using: {
      tsearch: { prefix: true }
  }


  def bookmarked_by?(user)
    return false if user.nil?

    bookmarks.where(user_id: user.id).exists?
  end


end
