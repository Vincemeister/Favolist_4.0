class ListsController < ApplicationController
  before_action :set_list, only: [:show, :edit, :update, :destroy, :add_product, :remove_product]

  def show
    @products = @list.products
  end

  def new
    @list = List.new
  end

  private

  def list_params
    params.require(:list).permit(:name, :description)
  end

  def set_list
    @list = List.find(params[:id])
  end
end
