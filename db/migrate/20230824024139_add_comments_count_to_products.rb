class AddCommentsCountToProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :comments_count, :integer
  end
end
