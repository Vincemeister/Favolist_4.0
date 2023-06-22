class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product, only: [:index, :create, :show]
  before_action :set_comment, only: [:replies, :show, :destroy]
  before_action :set_context, only: [:create] # to enable the jbuilder ender logic



  def create
    @comment = Comment.new(comment_params)
    @comment.product = @product
    @comment.user = current_user

    respond_to do |format|
      if @comment.save
        puts "Comment was saved. Context: #{@context}"

        format.json
      else
        format.html { render "products/show", status: :unprocessable_entity }
        format.json
      end
    end
  end


  def show
    @replies = @comment.replies.order(created_at: :asc)
  end

  def replies
    @parent_comment = Comment.find(params[:id])
    @replies = @parent_comment.replies.includes(:user).order(created_at: :desc)
  end


  def destroy
    @comment.destroy
    redirect_to product_comments_path(@comment.product)
  end


  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:body, :parent_comment_id)
  end

  def set_context
    @context = params[:comment][:context]
  end

end
