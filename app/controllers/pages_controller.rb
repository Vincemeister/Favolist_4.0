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
    @pagination_url = search_url

    @product_page = params[:page] || 1
    @list_page = params[:page] || 1





    @users = User.with_attached_avatar.includes(:followers).all
    @referrals = Referral.all.includes(:product)

    if current_user
      @user_bookmarks = Bookmark.where(user_id: current_user.id).pluck(:product_id)
    end

    if params[:query].present?
      search_products = Product.search_by_title_and_description_and_list_name_and_user_username(params[:query])
      search_lists = List.search_by_name_and_description_and_product_title_and_user_username(params[:query])

      # Filter the results with the viewable_by scope
      @products = Product.where(id: search_products.pluck(:id)).viewable_by(current_user).page(@product_page)
      @lists = List.where(id: search_lists.pluck(:id)).viewable_by(current_user).page(@list_page)

      @referrals = Referral.search_by_product_title_user_username_and_list_name(params[:query]).viewable_by(current_user)
      @users = User.search_by_user_username_and_bio_and_list_name(params[:query]) || []
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
      end
    end

    respond_to do |format|
      format.html
      format.json
      format.turbo_stream
    end
  end



  # def search
  #   @product_pagination_url = search_url
  #   @list_pagination_url = search_url

  #   @type = params[:type] || "product"  # default to product if no type is given

  #   case @type
  #   when "product"
  #     @products = Product.paginate(page: params[:page]) # or whatever logic you use
  #   when "list"
  #     @lists = List.paginate(page: params[:page])
  #   end

  #   @product_page = params[:product_page] || 1
  #   @list_page = params[:list_page] || 1

  #   @products = Product.viewable_by(current_user)
  #                     .includes(:list, photos_attachments: :blob, user: [{avatar_attachment: :blob}])
  #                     .page(@product_page)

  #   @lists = List.viewable_by(current_user).includes(:user, background_image_attachment: :blob).page(@list_page)



  #   # @lists = List.all.includes(:user, products: [{photos_attachments: :blob}])

  #   @referrals = Referral.all.includes(:product)
  #   @users = User.with_attached_avatar.includes(:followers).all

  #   @user_bookmarks = []

  #   if current_user
  #     @user_bookmarks = Bookmark.where(user_id: current_user.id).pluck(:product_id)
  #   end

  #   if params[:query].present?

  #     @page = params[:page] || 1

  #     # First execute the pg_search query
  #     search_products = Product.search_by_title_and_description_and_list_name_and_user_username(params[:query])



  #     search_lists = List.search_by_name_and_description_and_product_title_and_user_username(params[:query])


  #     # Then filter the results with the viewable_by scope
  #     @products = Product.where(id: search_products.pluck(:id)).viewable_by(current_user).page(@page)
  #     @lists = List.where(id: search_lists.pluck(:id)).viewable_by(current_user)

  #     # Different logic for referrals at this time
  #     @referrals = Referral.search_by_product_title_user_username_and_list_name(params[:query]).viewable_by(current_user)

  #     # Users can always be found
  #     @users = User.search_by_user_username_and_bio_and_list_name(params[:query]) || []
  #   end

  #   if current_user
  #     @user = current_user
  #     @suggested_users = User.all - current_user.followed
  #     @suggested_users = @suggested_users.sample(1)
  #   else
  #     @suggested_users = User.all.sample(1)
  #   end
  #   random_list = List.viewable_by(current_user).order("RANDOM()").first
  #   @suggested_lists = [random_list] if random_list



  #   respond_to do |format|
  #     format.html
  #     format.turbo_stream
  #     format.text { render partial: "pages/search_results", locals: {products: @products, lists: @lists, referrals: @referrals, users: @users }, formats: [:html] }
  #   end

  # end


  def creators
    @pagination_url = creators_url
    @page = params[:page] || 1
    @products = Product.includes(list: :user, photos_attachments: :blob, list: {user: {avatar_attachment: :blob}}).where(lists: { users: { is_creator: true }}).page(@page)
    @lists = List.includes(:user, background_image_attachment: :blob).where(users: { is_creator: true })
    @referrals = Referral.includes(product: { list: :user }).where(products: { lists: { users: { is_creator: true }}})
    @users = User.with_attached_avatar.includes(:followers).where(is_creator: true).all

    @user_bookmarks = []

    if current_user
      @user_bookmarks = Bookmark.where(user_id: current_user.id).pluck(:product_id)
    end

    if params[:query].present?
      @page = params[:page] || 1
      # First execute the pg_search query
      search_products = Product.search_by_title_and_description_and_list_name_and_user_username(params[:query]).where(lists: { users: { is_creator: true }})
      search_lists = List.search_by_name_and_description_and_product_title_and_user_username(params[:query]).where(users: { is_creator: true })

      # Then filter the results with the viewable_by scope
      @products = Product.where(id: search_products.pluck(:id)).viewable_by(current_user).page(@page)
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
      format.turbo_stream
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
