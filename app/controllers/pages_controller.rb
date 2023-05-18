class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @products = Product.all
  end

  def search
    @products = Product.search(params[:search])
    @lists = List.search(params[:search])
    @referrals = Referral.search(params[:search])
  end

end
