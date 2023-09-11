class AddIsCreatorToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :is_creator, :boolean,  default: false
  end
end
