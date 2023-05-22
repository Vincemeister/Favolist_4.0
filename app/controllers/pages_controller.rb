class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @products = Product.all
  end

  def search
    if params[:search].present?
      @products = Product.search_by_title_and_description_and_list_name_and_user_username(params[:search][:query])
      @lists = List.search_by_name_and_description_and_product_title_and_user_username(params[:search][:query])
      @referrals = Referral.search_by_product_title_user_username_and_list_name(params[:search][:query])

      #@users = User.search_by_product_title_user_username_and_list_name(params[:search][:query])
    else
      @products = []
      @lists = []
      @referrals = []
      @users = []
    end
  end

end
