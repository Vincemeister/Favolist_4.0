class User < ApplicationRecord
  include PgSearch::Model
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_many :lists, dependent: :destroy
  has_many :products, through: :lists
  has_many :referrals, through: :lists, source: :products

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  validates :username, presence: true, uniqueness: true

  has_one_attached :avatar

  has_many :follower_relationships, foreign_key: :followed_id, class_name: 'Follow', dependent: :destroy
  has_many :followers, through: :follower_relationships, source: :follower, dependent: :destroy

  has_many :followed_relationships, foreign_key: :follower_id, class_name: 'Follow'
  has_many :followed, through: :followed_relationships, source: :followed, dependent: :destroy

  pg_search_scope :search_by_user_username_and_list_name,
  against: [:username, :bio],
  associated_against: {
    lists: [:name]
  },
  using: {
      tsearch: { prefix: true }
  }


  def follow(user_id)
    followed_relationships.create(followed_id: user_id)
  end

  def unfollow(user_id)
    followed_relationships.find_by(followed_id: user_id).destroy
  end

  def remove_follower(user_id)
    follower_relationships.find_by(follower_id: user_id).destroy
  end

  def is_following?(user_id)
    relationship = Follow.find_by(follower_id: id, followed_id: user_id)
    relationship ? true : false
  end

  def follows
    @user = User.find(params[:id])
    @followers = @user.followers
    @followed = @user.followed
  end

end
