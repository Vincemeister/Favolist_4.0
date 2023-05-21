class ListsController < ApplicationController
  before_action :set_list, only: [:show, :edit, :update, :destroy, :add_product, :remove_product]

  def show
    @products = @list.products
  end

  def new
    @list = List.new
  end

  def create
    @list = List.new(list_params)
    @user = current_user
    @list.user = @user
    if @list.save
      redirect_to list_path(@list)
    else
      render :new
    end
  end

  private

  def list_params
    params.require(:list).permit(:name, :description)
  end

  def set_list
    @list = List.find(params[:id])
  end
end
