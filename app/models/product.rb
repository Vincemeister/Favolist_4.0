class Product < ApplicationRecord
include PgSearch::Model

belongs_to :list
has_one :user, through: :list
has_many :referrals, dependent: :destroy
has_many :comments, dependent: :destroy
has_many_attached :photos, dependent: :destroy
has_one_attached :logo, dependent: :destroy



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
