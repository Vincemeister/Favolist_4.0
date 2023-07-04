class Product < ApplicationRecord
  scope :viewable_by, -> (user) {
    joins(list: :user).where(users: { id: User.viewable_by(user).pluck(:id) })
  }


  include PgSearch::Model

  belongs_to :list, optional: true, counter_cache: true
  has_one :user, through: :list

  has_one :referral, dependent: :destroy
  accepts_nested_attributes_for :referral


  has_many :comments, dependent: :destroy



  has_one_attached :logo, dependent: :destroy
  has_many_attached :photos, dependent: :destroy

  has_many :bookmarks, dependent: :destroy
  has_many :bookmarked_by, through: :bookmarks, source: :user

  validates :review, presence: true
  validates :description, presence: true


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

  def viewable_by?(user)
    User.viewable_by(user).include?(self.list.user)
  end


end
