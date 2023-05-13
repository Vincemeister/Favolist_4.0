class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :title
      t.float :price
      t.text :review
      t.text :description
      t.references :list, null: false, foreign_key: true
      t.string :url

      t.timestamps
    end
  end
end
