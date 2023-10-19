class ChangePriceToMoney < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :price_cents, :integer
    add_column :products, :price_currency, :string, default: "USD", null: false
  end
end
