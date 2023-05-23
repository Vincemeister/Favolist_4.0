class RenameParentCommentToParentCommentIdInComments < ActiveRecord::Migration[7.0]
  def change
    rename_column :comments, :parent_comment, :parent_comment_id
  end
end
