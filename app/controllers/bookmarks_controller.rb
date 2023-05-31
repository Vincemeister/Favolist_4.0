class BookmarksController < ApplicationController
  before_action :set_product, only: [:bookmark, :unbookmark]

  def index
    @bookmarks = Bookmark.where(user: current_user)
    @products = Product.joins(:bookmarks).where(bookmarks: { user: current_user })
  end



  def bookmark
    bookmark = Bookmark.new(user: current_user, product: @product)
    if bookmark.save
      render json: { action: "bookmark", bookmarksCount: @product.bookmarks.count, unbookmark_path: unbookmark_product_path(@product) }
    else
      head :unprocessable_entity
    end
  end

  def unbookmark
    Rails.logger.debug "Current product: #{@product.inspect}"
    bookmark = Bookmark.find_by(user: current_user, product: @product)
    Rails.logger.debug "Found bookmark: #{bookmark.inspect}"

    if bookmark.destroy
      render json: { action: "unbookmark", bookmarksCount: @product.bookmarks.count, bookmark_path: bookmark_product_path(@product) }
    else
      head :unprocessable_entity
    end
  end



  private

  def set_product
    @product = Product.find(params[:id])
  end
end
