class AddSubscriptionToProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :is_subscription, :boolean, default: false
    add_column :products, :subscription_type, :string
  end
end
