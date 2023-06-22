class Notification < ApplicationRecord
  belongs_to :actor, class_name: 'User'
  belongs_to :recipient, class_name: 'User'
end
