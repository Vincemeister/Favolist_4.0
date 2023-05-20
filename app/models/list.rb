class List < ApplicationRecord
  include PgSearch::Model

  belongs_to :user
  has_many :products, dependent: :destroy

  pg_search_scope :search_by_title_and_description_and_list_name_and_user_username,
  against: [:title, :description],
  associated_against: {
    list: [:name],
    user: [:username]
  },
  using: {
    tsearch: { prefix: true }
  }
end
