class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home, :search, :no_permission ]

  def home
    @products = Product.viewable_by(current_user)
    if current_user
      @user = current_user
      @suggested_users = User.all - current_user.followed
      @suggested_users = @suggested_users.sample(1)
    end
    @suggested_lists = List.all.first
    # @suggested_lists = List.all.sample(1)
    @suggested_lists = [User.first.lists.sample]
  end

  def search
    @products = Product.all
    @lists = List.all
    @referrals = Referral.all
    @users = User.all
    if params[:query].present?
      # First execute the pg_search query
      search_products = Product.search_by_title_and_description_and_list_name_and_user_username(params[:query])
      search_lists = List.search_by_name_and_description_and_product_title_and_user_username(params[:query])


      # Then filter the results with the viewable_by scope
      @products = Product.where(id: search_products.pluck(:id)).viewable_by(current_user)
      @lists = List.where(id: search_lists.pluck(:id)).viewable_by(current_user)

      # Different logic for referrals at this time
      @referrals = Referral.search_by_product_title_user_username_and_list_name(params[:query]).viewable_by(current_user)

      # Users can always be found
      @users = User.search_by_user_username_and_bio_and_list_name(params[:query]) || []
    end

    if current_user
      @user = current_user
      @suggested_users = User.all - current_user.followed
      @suggested_users = @suggested_users.sample(1)
    end
    @suggested_lists = List.all.first
    # @suggested_lists = List.all.sample(1)
    @suggested_lists = [User.first.lists.sample]


    respond_to do |format|
      format.html # Follow regular flow of Rails
      format.text { render partial: "pages/search_results", locals: {products: @products, lists: @lists, referrals: @referrals, users: @users }, formats: [:html] }
    end
  end


  def test
  end

  def no_permission
  end

end
