class AddDefaultValuesToProducts < ActiveRecord::Migration[7.0]
  def change
    change_column_default :products, :bookmarks_count, 0
    change_column_default :products, :comments_count, 0
  end
end
