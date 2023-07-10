class AddDefaultToDuplicatedCount < ActiveRecord::Migration[7.0]
  def change
    change_column_default :products, :duplicated_count, 0
  end
end
