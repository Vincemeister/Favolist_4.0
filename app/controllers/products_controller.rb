class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  def index
    @products = Product.all
  end

  def show
  end

  def new
    @product  = Product.new
    @user = current_user
  end

  def create
    @product = Product.new(product_params)
    @product.logo.attach(params[:product][:logo])
    @product.photos.attach(params[:product][:photos])
    if @product.save
      redirect_to list_path(@product.list)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_to list_path(@product.list), notice: 'Product was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    Rails.logger.debug "Attempting to destroy product with id: #{params[:id]}"
   @product.destroy!
  end


  private

  def product_params
    params.require(:product).permit(:title, :price, :review, :description, :url, :list_id)
  end

  def set_product
    @product = Product.find(params[:id])
  end


end
