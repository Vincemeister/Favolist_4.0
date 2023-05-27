if @comment.persisted?
  json.inserted_item render(partial: "comments/comment_reply", formats: :html, locals: { reply: @comment} )
  json.form render(partial: "comments/direct_reply_form", formats: :html, locals: { product: @comment.product, parent_comment: @comment.parent_comment , comment: Comment.new } )
end
