class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @products = Product.all
    if current_user
      @user = current_user
      @suggested_users = User.all - current_user.followed
      @suggested_users = @suggested_users.sample(2)
    end
    @suggested_lists = List.all.sample(1)
  end

  def search
    if params[:search].present?
      @products = Product.search_by_title_and_description_and_list_name_and_user_username(params[:search][:query])
      @lists = List.search_by_name_and_description_and_product_title_and_user_username(params[:search][:query])
      @referrals = Referral.search_by_product_title_user_username_and_list_name(params[:search][:query])
      @users = User.search_by_user_username_and_bio_and_list_name(params[:search][:query])
    else
      @products = []
      @lists = []
      @referrals = []
      @users = []
    end
  end

  def test
  end

  def no_permission
  end

end
