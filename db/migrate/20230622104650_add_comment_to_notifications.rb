class AddCommentToNotifications < ActiveRecord::Migration[7.0]
  def change
    add_reference :notifications, :comment, foreign_key: true
  end
end
