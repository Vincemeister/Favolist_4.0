
class User < ApplicationRecord
  require 'open-uri'


  scope :viewable_by, -> (user) {
    if user
      where(privacy: 'public')
        .or(where(id: user.followed.pluck(:id), privacy: 'private'))
        .or(where(id: user.id))
    else
      where(privacy: 'public')
    end
  }

  before_create :set_default_privacy

  include PgSearch::Model
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_many :lists, dependent: :destroy
  has_many :products, through: :lists
  has_many :referrals, through: :products
  has_many :notifications_sent, class_name: 'Notification', foreign_key: 'actor_id', dependent: :destroy
  has_many :notifications_received, class_name: 'Notification', foreign_key: 'recipient_id', dependent: :destroy

  validates :password, length: { minimum: 6 }, if: :password_required?




  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  validates :username, presence: true, uniqueness: true

  validates :intro, length: { maximum: 280 }
  validates :bio, length: { maximum: 5000 }


  has_one_attached :avatar

  after_commit :set_default_avatar, on: :create


  has_many :follower_relationships, foreign_key: :followed_id, class_name: 'Follow', dependent: :destroy
  has_many :followers, through: :follower_relationships, source: :follower, dependent: :destroy

  has_many :followed_relationships, foreign_key: :follower_id, class_name: 'Follow'
  has_many :followed, through: :followed_relationships, source: :followed, dependent: :destroy



  pg_search_scope :search_by_user_username_and_bio_and_list_name,
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

  def mutual_follows_with(user)
    self.followed & user.followers
  end

  def set_default_avatar
    unless avatar.attached?
      file = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1693654445/Favolist%204.0/app%20assets/profile_avatar_at2r80.jpg")
      avatar.attach(io: file, filename: 'default_avatar.jpg', content_type: 'image/jpg')
    end
  end

  private

  def set_default_privacy
    self.privacy ||= 'public'
  end

  # def set_default_avatar
  #   unless avatar.attached?
  #     file = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1693654445/Favolist%204.0/app%20assets/profile_avatar_at2r80.jpg")
  #     avatar.attach(io: file, filename: 'default_avatar.jpg', content_type: 'image/jpg')
  #   end
  # end



end
