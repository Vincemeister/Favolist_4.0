class RemoveCurrencyFromProducts < ActiveRecord::Migration[7.0]
  def change
    remove_column :products, :currency, :string
  end
end
