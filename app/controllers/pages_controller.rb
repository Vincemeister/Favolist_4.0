class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @products = Product.all
  end

  def search
    @products = Product.search_by_title_and_description_and_list_title_and_user_username(params[:query])

    @lists = List.search(params[:search])
    @referrals = Referral.search(params[:search])
  end

end
