class Referral < ApplicationRecord
  belongs_to :product

  validates :code, presence: true
  validates :details, presence: true
end
