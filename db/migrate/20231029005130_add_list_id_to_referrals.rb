class AddListIdToReferrals < ActiveRecord::Migration[7.0]
  def change
    add_reference :referrals, :list, foreign_key: true
  end
end
