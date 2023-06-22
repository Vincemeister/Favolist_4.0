class Follow < ApplicationRecord
  belongs_to :follower, foreign_key: 'follower_id', class_name: 'User'
  belongs_to :followed, foreign_key: 'followed_id', class_name: 'User', counter_cache: :followers_count


  after_create :create_notification

  private

  def create_notification
    Notification.create(
      actor: follower,
      recipient: followed,
      action: 'followed',
      read: false
    )
  end

  def increment_followed_user_followers_count
    followed.increment(:followers_count).save
  end

  def decrement_followed_user_followers_count
    followed.decrement(:followers_count).save
  end
end
