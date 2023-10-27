class Product < ApplicationRecord
  after_save :update_photos_count
  after_destroy :trigger_list_update


  scope :viewable_by, -> (user) {
    joins(list: :user).where(users: { id: User.viewable_by(user).pluck(:id) })
  }


  include PgSearch::Model

  belongs_to :list, optional: true, counter_cache: true
  has_one :user, through: :list

  has_one :referral, dependent: :destroy
  accepts_nested_attributes_for :referral


  has_many :comments, dependent: :destroy

  monetize :price_cents, as: "price"


  has_one_attached :logo, dependent: :destroy
  has_many_attached :photos, dependent: :destroy

  has_many :bookmarks, dependent: :destroy
  has_many :bookmarked_by, through: :bookmarks, source: :user

  acts_as_list scope: :list_id # replace list_id with whatever your scope should be

  validates :review, presence: true
  validates :description, presence: true
  validates :subscription_type, inclusion: { in: ['one_time', 'monthly', 'yearly'],
    message: "%{value} is not a valid purchase type" }

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

  # NEW METHOD THAT'S HELPS NOT CREATE A NEW DATABASE REQUEST ALL THE TIME - IN THE CONROLLERS NEED TO ALSO SET
  # @user_bookmarks = Bookmark.where(user_id: current_user.id, product_id: @products.map(&:id)).pluck(:product_id)

  def bookmarked_by_user?(user_bookmarks)
    user_bookmarks.include?(self.id)
  end


  def viewable_by?(user)
    User.viewable_by(user).include?(self.list.user)
  end

  private

  def update_photos_count
    self.update_column(:photos_count, self.photos.length)
  end


  def trigger_list_update
    Rails.logger.info "Triggering list update for List ID: #{list.id}" if list.present?
    list.regenerate_background if list.present?
  end

end
