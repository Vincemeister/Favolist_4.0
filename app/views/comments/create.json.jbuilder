

if @comment.persisted?
  if @comment.parent_comment.present? && @context == nil
    Rails.logger.debug "Rendering comment_reply."

    json.inserted_item render(partial: "comments/comment_reply", formats: :html, locals: { reply: @comment } )
    json.form render(partial: "comments/direct_reply_form", formats: :html, locals: { product: @comment.product, parent_comment: @comment.parent_comment , reply: Comment.new, remote: true } )
  elsif @context == "comment"
    Rails.logger.debug "Rendering comment."

    json.inserted_item render(partial: "comments/comment", formats: :html, locals: { comment: @comment, context: "comment" } )
    json.form render(partial: "comments/commentform", formats: :html, locals: { product: @comment.product, parent_comment: nil , comment: Comment.new, context: @context, remote: true } )
  elsif @context == "reply"
    Rails.logger.debug "Rendering reply."

    json.inserted_item render(partial: "comments/comment", formats: :html, locals: { comment: @comment } )
    json.form render(partial: "comments/commentform", formats: :html, locals: { product: @comment.product, parent_comment: @comment.parent_comment, comment: Comment.new, context: "reply", remote: true } )
  end
end
