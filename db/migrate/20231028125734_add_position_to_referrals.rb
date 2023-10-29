class AddPositionToReferrals < ActiveRecord::Migration[7.0]
  def change
    add_column :referrals, :position, :integer
  end
end
