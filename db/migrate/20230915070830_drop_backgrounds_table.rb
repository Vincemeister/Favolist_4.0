class DropBackgroundsTable < ActiveRecord::Migration[7.0]
  def change
    drop_table :backgrounds
  end
end
