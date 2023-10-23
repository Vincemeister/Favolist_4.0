class Bookmark < ApplicationRecord
  belongs_to :user
  belongs_to :product, counter_cache: true
  has_many :notifications


  validates :user, uniqueness: { scope: :product }

  after_create :create_notification


  private

  def create_notification
    Notification.create(
      actor: user,
      recipient: product.user,
      action: 'bookmarked',
      bookmark: self,  # Add this line to associate the bookmark with the notification
      read: false
    )
  end
end
