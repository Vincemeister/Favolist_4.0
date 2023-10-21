class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home, :search, :no_permission, :beta, :about, :creators ]

  def home
    @start_product_id = params[:product_id]

    @page = params[:page] || 1
    @products = Product.viewable_by(current_user)
    .includes(:list, photos_attachments: :blob, user: [{avatar_attachment: :blob}])
    .order(created_at: :desc)
    .page(@page)


    if current_user
      @user_bookmarks = Bookmark.where(user_id: current_user.id).pluck(:product_id)
      @suggested_users = (User.where.not(id: current_user.id) - current_user.followed).sample(1)
      random_list = List.joins(:user)
                        .merge(User.viewable_by(current_user))
                        .where.not(user_id: current_user.id)
                        .order("RANDOM()")
                        .first
      @suggested_lists = random_list ? [random_list] : []
    else
      @user_bookmarks = []
      @suggested_users = User.all.sample(1)
      random_list = List.joins(:user)
                        .merge(User.viewable_by(nil))
                        .order("RANDOM()")
                        .first
      @suggested_lists = random_list ? [random_list] : []
    end
  end

  def search
    if current_user
      @user_bookmarks = Bookmark.where(user_id: current_user.id).pluck(:product_id)
      @suggested_users = (User.where.not(id: current_user.id) - current_user.followed).sample(1)
      random_list = List.joins(:user)
                        .merge(User.viewable_by(current_user))
                        .where.not(user_id: current_user.id)
                        .order("RANDOM()")
                        .first
      @suggested_lists = random_list ? [random_list] : []
    else
      @user_bookmarks = []
      @suggested_users = User.all.sample(1)
      random_list = List.joins(:user)
                        .merge(User.viewable_by(nil))
                        .order("RANDOM()")
                        .first
      @suggested_lists = random_list ? [random_list] : []
    end


    puts "SEARCH ACTION INITIALIZED"
    @products_count = Product.viewable_by(current_user).count
    @lists_count = List.viewable_by(current_user).count
    @referrals_count = Referral.viewable_by(current_user).count
    @users_count = User.count
    puts "PRODUCT COUNT: #{@products_count}"
    puts "LIST COUNT: #{@lists_count}"
    puts "REFERRAL COUNT: #{@referrals_count}"
    puts "USER COUNT: #{@users_count}"


    puts "PARAMS: #{params}"
    puts "PARAMS TYPE: #{params[:type]}"
    @type = params[:type] || "product"  # default to product if no type is given
    puts "@TYPE: #{@type}"
    puts "-------------------------------------------------------------------------------------------------------------------"
    puts "PARAMS QUERY PRESENT ??? #{params[:query].present?}"



    puts "-----------PAGES-SETTING-----------------------"
    puts "PAGE PARAMS: #{params[:page]}"

    @product_page = params[:page] || 1
    puts "PRODUCT PAGE: #{@product_page}"
    @list_page = params[:page] || 1
    puts "LIST PAGE: #{@list_page}"
    @referral_page = params[:page] || 1
    puts "REFERRAL PAGE: #{@referral_page}"
    @user_page = params[:page] || 1
    puts "USER PAGE: #{@user_page}"

    if current_user
      @user_bookmarks = Bookmark.where(user_id: current_user.id).pluck(:product_id)
    end

    if params[:query].present? && params.dig(:query, :query).present?
      puts "QUERY PRESENT"
      puts "QUERY: #{params[:query][:query]}"
      @pagination_url = search_url(query: { query: params[:query][:query] })
      puts "QUERY PRESENT PAGINATION URL: #{@pagination_url}"
      puts "QUERY PRESENT"
      puts "QUERY: #{params[:query]}"
      if params.dig(:query, :query).present?
        puts "QUERY QUERY: #{params[:query][:query]}"
      end

      search_products = Product.search_by_title_and_description_and_list_name_and_user_username(params[:query][:query])
      search_lists = List.search_by_name_and_description_and_product_title_and_user_username(params[:query][:query])

      # Filter the results with the viewable_by scope
      @products = Product.where(id: search_products.pluck(:id)).viewable_by(current_user).page(@product_page)
      @lists = List.where(id: search_lists.pluck(:id)).viewable_by(current_user).page(@list_page)
      @referrals = Referral.search_by_product_title_user_username_and_list_name(params[:query][:query]).viewable_by(current_user).page(@referral_page)
      @users = User.search_by_user_username_and_bio_and_list_name(params[:query][:query])
      .order(followers_count: :desc)
      .page(@users_page) || []

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
      puts "QUERY NOT PRESENT"
      @pagination_url = search_url
      puts "QUERY NOT PRESENT PAGINATION URL: #{@pagination_url}"
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
        @users = User.includes(:followers).order(followers_count: :desc).page(@user_page)
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

    if current_user
      @user_bookmarks = Bookmark.where(user_id: current_user.id).pluck(:product_id)
      @suggested_users = (User.where.not(id: current_user.id) - current_user.followed).sample(1)
      random_list = List.joins(:user)
                        .merge(User.viewable_by(current_user))
                        .where.not(user_id: current_user.id)
                        .order("RANDOM()")
                        .first
      @suggested_lists = random_list ? [random_list] : []
    else
      @user_bookmarks = []
      @suggested_users = User.all.sample(1)
      random_list = List.joins(:user)
                        .merge(User.viewable_by(nil))
                        .order("RANDOM()")
                        .first
      @suggested_lists = random_list ? [random_list] : []
    end

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
