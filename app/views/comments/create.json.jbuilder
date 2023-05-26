if @comment.persisted?
  if @comment.parent_comment_id
    json.form render(partial: "comments/replyform", formats: :html, locals: {product: @product, comment: Comment.new, parent_comment_id: @comment.parent_comment_id})
    json.inserted_item render(partial: "comments/reply", formats: :html, locals: {reply: @comment})
  else
    json.form render(partial: "comments/commentform", formats: :html, locals: {product: @product, comment: Comment.new})
    json.inserted_item render(partial: "comments/comment", formats: :html, locals: {comment: @comment})
  end
else
  if @comment.parent_comment_id
    json.form render(partial: "comments/replyform", formats: :html, locals: {product: @product, comment: @comment, parent_comment_id: @comment.parent_comment_id})
  else
    json.form render(partial: "comments/commentform", formats: :html, locals: {product: @product, comment: @comment})
  end
end
