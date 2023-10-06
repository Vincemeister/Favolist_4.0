class ChangeDefaultFollowersCountOnUsers < ActiveRecord::Migration[7.0]
  def change
    change_column_default :users, :followers_count, from: nil, to: 0
  end
end
