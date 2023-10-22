class RemoveIsSubscriptionFromProducts < ActiveRecord::Migration[7.0]
  def change
    remove_column :products, :is_subscription, :boolean
  end
end
