class Notification < ApplicationRecord
  belongs_to :actor, class_name: 'User'
  belongs_to :recipient, class_name: 'User'
  belongs_to :comment, optional: true  # You can use `optional: true` if a notification might not always belong to a comment

  def mark_as_read
    self.update(read: true)
  end

end
