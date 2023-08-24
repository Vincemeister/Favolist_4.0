class AddBookmarksCountToProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :bookmarks_count, :integer
  end
end
