class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home, :search, :no_permission, :beta, :about, :creators ]

  def home
    @start_product_id = params[:product_id]

    @page = params[:page] || 1
    @products = Product.viewable_by(current_user)
                       .includes(:list, photos_attachments: :blob, user: [{avatar_attachment: :blob}])
                       .page(@page)


    @user_bookmarks = []

    if current_user
      @user_bookmarks = Bookmark.where(user_id: current_user.id).pluck(:product_id)
    end


    if current_user
      @user = current_user
      @suggested_users = User.all - current_user.followed
      @suggested_users = @suggested_users.sample(1)
    else
      @suggested_users = User.all.sample(1)
    end
    random_list = List.viewable_by(current_user).order("RANDOM()").first
    @suggested_lists = [random_list] if random_list

  end


  def search
    @products = Product.all.includes(:list, photos_attachments: :blob, user: [{avatar_attachment: :blob}])
    @lists = List.all.includes(:user, background_image_attachment: :blob)

    # @lists = List.all.includes(:user, products: [{photos_attachments: :blob}])

    @referrals = Referral.all.includes(:product)
    @users = User.with_attached_avatar.includes(:followers).all

    @user_bookmarks = []

    if current_user
      @user_bookmarks = Bookmark.where(user_id: current_user.id).pluck(:product_id)
    end

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
    else
      @suggested_users = User.all.sample(1)
    end
    random_list = List.viewable_by(current_user).order("RANDOM()").first
    @suggested_lists = [random_list] if random_list



    respond_to do |format|
      format.html # Follow regular flow of Rails
      format.text { render partial: "pages/search_results", locals: {products: @products, lists: @lists, referrals: @referrals, users: @users }, formats: [:html] }
    end
  end


  def creators
    @products = Product.includes(list: :user, photos_attachments: :blob, list: {user: {avatar_attachment: :blob}}).where(lists: { users: { is_creator: true }})
    @lists = List.includes(:user, background_image_attachment: :blob).where(users: { is_creator: true })
    @referrals = Referral.includes(product: { list: :user }).where(products: { lists: { users: { is_creator: true }}})
    @users = User.with_attached_avatar.includes(:followers).where(is_creator: true).all

    @user_bookmarks = []

    if current_user
      @user_bookmarks = Bookmark.where(user_id: current_user.id).pluck(:product_id)
    end

    if params[:query].present?
      # First execute the pg_search query
      search_products = Product.search_by_title_and_description_and_list_name_and_user_username(params[:query]).where(lists: { users: { is_creator: true }})
      search_lists = List.search_by_name_and_description_and_product_title_and_user_username(params[:query]).where(users: { is_creator: true })

      # Then filter the results with the viewable_by scope
      @products = Product.where(id: search_products.pluck(:id)).viewable_by(current_user)
      @lists = List.where(id: search_lists.pluck(:id)).viewable_by(current_user)

      # Different logic for referrals at this time
      @referrals = Referral.search_by_product_title_user_username_and_list_name(params[:query]).viewable_by(current_user).where(products: { lists: { users: { is_creator: true }}})

      # Users can always be found
      @users = User.search_by_user_username_and_bio_and_list_name(params[:query]).where(is_creator: true) || []
    end

    if current_user
      @user = current_user
      @suggested_users = User.where(is_creator: true) - current_user.followed
      @suggested_users = @suggested_users.sample(1)
    else
      @suggested_users = User.where(is_creator: true).sample(1)
    end

    random_list = List.viewable_by(current_user).where(users: { is_creator: true }).order("RANDOM()").first
    @suggested_lists = [random_list] if random_list

    respond_to do |format|
      format.html # Follow regular flow of Rails
      format.text { render partial: "pages/search_results", locals: { products: @products, lists: @lists, referrals: @referrals, users: @users }, formats: [:html] }
    end
  end



  def about
  end

  def beta
  end

  def test
  end

  def no_permission
  end

end
