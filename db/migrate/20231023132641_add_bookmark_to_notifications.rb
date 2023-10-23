class AddBookmarkToNotifications < ActiveRecord::Migration[7.0]
  def change
    add_reference :notifications, :bookmark, foreign_key: true
  end
end
