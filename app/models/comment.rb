class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :product
  has_many :replies, class_name: 'Comment', foreign_key: 'parent_comment_id', dependent: :destroy
  has_many :notifications, dependent: :destroy
  belongs_to :parent_comment, class_name: 'Comment', optional: true

  after_commit :create_notification, on: :create

  private

  def create_notification
    # This assumes that a Comment belongs to a User and a Product, adjust accordingly if not

    # If this comment is a reply to another comment
    if parent_comment.present?
      return if user == parent_comment.user  # Don't notify if replying to own comment
      Notification.create(
        actor: user,
        recipient: parent_comment.user,  # Notify the user who wrote the parent comment
        action: 'replied',
        comment: self  # Add the comment to the notification
      )
    else  # If this is a new comment, not a reply
      return if user == product.user  # Don't notify if commenting on own product
      Notification.create(
        actor: user,
        recipient: product.user,  # Notify the product owner
        action: 'commented',
        comment: self  # Add the comment to the notification
      )
    end
  end

end
