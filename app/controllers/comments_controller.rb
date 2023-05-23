class CommentsController < ApplicationController
  before_action :authenticate_user!

  def create
    @product = Product.find(params[:product_id])
    @comment = @product.comments.new(comment_params)
    @comment.user = current_user

    respond_to do |format|
      if @comment.save
        format.html { redirect_to product_comments_path(@product) }
        format.json
      else
        format.html { render "products/show", status: :unprocessable_entity }
        format.json
      end
    end
  end

  def replies
    @parent_comment = Comment.find(params[:id])
    @replies = @parent_comment.replies.includes(:user).order(created_at: :desc)
  end

  private

  def comment_params
    params.require(:comment).permit(:body, :user_id, :product_id, :parent_comment_id)
  end
end
