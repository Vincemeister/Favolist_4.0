class AddPhotosCountToProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :photos_count, :integer, default: 0
  end
end
