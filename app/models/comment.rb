class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :product
  has_many :replies, class_name: 'Comment', foreign_key: 'parent_comment_id', dependent: :destroy
  belongs_to :parent, class_name: 'Comment', optional: true
end
