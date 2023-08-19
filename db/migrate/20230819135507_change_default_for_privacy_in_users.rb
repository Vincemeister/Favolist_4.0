class ChangeDefaultForPrivacyInUsers < ActiveRecord::Migration[7.0]
  def change
    change_column_default :users, :privacy, 'public'
  end
end
