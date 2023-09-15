class CreateBackgrounds < ActiveRecord::Migration[7.0]
  def change
    create_table :backgrounds do |t|
      t.string :image
      t.references :list, null: false, foreign_key: true

      t.timestamps
    end
  end
end
