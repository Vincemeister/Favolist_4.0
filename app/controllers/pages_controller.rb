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
    @products_count = Product.viewable_by(current_user).count
    @lists_count = List.viewable_by(current_user).count
    @referrals_count = Referral.viewable_by(current_user).count
    @users_count = User.count

    @user_bookmarks = []
    if current_user
      @user_bookmarks = Bookmark.where(user_id: current_user.id).pluck(:product_id)
    end
    if current_user
      @suggested_users = User.all - current_user.followed
      @suggested_users = @suggested_users.sample(1)
    else
      @suggested_users = User.all.sample(1)
    end
    random_list = List.viewable_by(current_user).order("RANDOM()").first
    @suggested_lists = [random_list] if random_list

    @type = params[:type] || "product"  # default to product if no type is given
    if params[:query].present? && params[:query][:query].present?
      @pagination_url = search_url(query: { query: params[:query][:query] })
    else
      @pagination_url = search_url
    end



    @product_page = params[:page] || 1
    @list_page = params[:page] || 1
    @referral_page = params[:page] || 1
    @user_page = params[:page] || 1

    if current_user
      @user_bookmarks = Bookmark.where(user_id: current_user.id).pluck(:product_id)
    end

    if params[:query].present?
      search_products = Product.search_by_title_and_description_and_list_name_and_user_username(params[:query][:query])
      search_lists = List.search_by_name_and_description_and_product_title_and_user_username(params[:query][:query])

      # Filter the results with the viewable_by scope
      @products = Product.where(id: search_products.pluck(:id)).viewable_by(current_user).page(@product_page)
      @lists = List.where(id: search_lists.pluck(:id)).viewable_by(current_user).page(@list_page)
      @referrals = Referral.search_by_product_title_user_username_and_list_name(params[:query][:query]).viewable_by(current_user).page(@referral_page)
      @users = User.search_by_user_username_and_bio_and_list_name(params[:query][:query]).page(@users_page) || []

      #counts
      @products_count = search_products.count
      @lists_count = @lists.count
      @referrals_count = @referrals.count
      @users_count = @users.count

      case @type
      when "product"
        @products = Product.where(id: search_products.pluck(:id)).viewable_by(current_user).page(@product_page)
      when "list"
        @lists = List.where(id: search_lists.pluck(:id)).viewable_by(current_user).page(@list_page)
      when "referral"
        @referrals = Referral.search_by_product_title_user_username_and_list_name(params[:query][:query]).viewable_by(current_user).page(@referral_page)
      when "user"
        @users = User.search_by_user_username_and_bio_and_list_name(params[:query][:query]).page(@users_page) || []
      end

    else
      case @type
      when "product"
        @products = Product.viewable_by(current_user)
                           .includes(:list, photos_attachments: :blob, user: [{avatar_attachment: :blob}])
                           .page(@product_page)
      when "list"
        @lists = List.viewable_by(current_user)
                     .includes(:user, background_image_attachment: :blob)
                     .page(@list_page)
      when "referral"
        @referrals = Referral.viewable_by(current_user).page(@referral_page)
      when "user"
        @users = User.includes(:followers).all.page(@user_page)
      end
    end

    respond_to do |format|
      format.html
      format.json
      format.turbo_stream
      format.text { render partial: "pages/search_results", locals: { products: @products, lists: @lists, referrals: @referrals, users: @users, pagination_url: @pagination_url  }, formats: [:html] }
    end
  end



  def creators
    @products_count = Product.where(lists: { users: { is_creator: true }}).viewable_by(current_user).count
    @lists_count = List.where(users: { is_creator: true }).viewable_by(current_user).count
    @referrals_count = Referral.where(products: { lists: { users: { is_creator: true }}}).viewable_by(current_user).count
    @users_count = User.where(is_creator: true).count



    @user_bookmarks = []
    if current_user
      @user_bookmarks = Bookmark.where(user_id: current_user.id).pluck(:product_id)
    end
    if current_user
      @suggested_users = User.where(is_creator: true) - current_user.followed
      @suggested_users = @suggested_users.sample(1)
    else
      @suggested_users = User.where(is_creator: true).sample(1)
    end
    random_list = List.viewable_by(current_user).where(users: { is_creator: true }).order("RANDOM()").first
    @suggested_lists = [random_list] if random_list


    @type = params[:type] || "product"  # default to product if no type is given
    @pagination_url = creators_url

    @product_page = params[:page] || 1
    @list_page = params[:page] || 1
    @referral_page = params[:page] || 1
    @user_page = params[:page] || 1


    if params[:query].present?
      search_products = Product.search_by_title_and_description_and_list_name_and_user_username(params[:query]).where(lists: { users: { is_creator: true }})
      search_lists = List.search_by_name_and_description_and_product_title_and_user_username(params[:query]).where(users: { is_creator: true })

      # Filter the results with the viewable_by scope
      @products = Product.where(id: search_products.pluck(:id)).viewable_by(current_user).page(@product_page)
      @lists = List.where(id: search_lists.pluck(:id)).viewable_by(current_user).page(@list_page)
      # Different logic for referrals at this time
      @referrals = Referral.search_by_product_title_user_username_and_list_name(params[:query]).viewable_by(current_user).where(products: { lists: { users: { is_creator: true }}}).page(@referral_page)
      # Users can always be found
      @users = User.search_by_user_username_and_bio_and_list_name(params[:query]).where(is_creator: true) || []
    else
      case @type
      when "product"
        @products = Product.viewable_by(current_user)
                           .includes(:list, photos_attachments: :blob, user: [{avatar_attachment: :blob}]).where(lists: { users: { is_creator: true }})
                           .page(@product_page)
      when "list"
        @lists = List.viewable_by(current_user)
                     .includes(:user, background_image_attachment: :blob).where(users: { is_creator: true })
                     .page(@list_page)
      when "referral"
        @referrals = Referral.viewable_by(current_user).where(products: { lists: { users: { is_creator: true }}}).page(@referral_page)
      when "user"
        @users = User.includes(:followers).where(is_creator: true).all.page(@user_page)
      end
    end

    respond_to do |format|
      format.html # Follow regular flow of Rails
      format.turbo_stream
      format.text { render partial: "pages/search_results", locals: { products: @products, lists: @lists, referrals: @referrals, users: @users, pagination_url: @pagination_url  }, formats: [:html] }
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
