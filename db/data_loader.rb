require "csv"
require "open-uri"


# puts "destroying all users"
# User.destroy_all


# i = 0
# CSV.foreach(profiles_csv, headers: :first_row, header_converters: :symbol, encoding: 'utf-8') do |row|
#   puts "----------------- ROW #{i} -----------------"
#   user = User.create!(
#       username: row[:profile],
#       bio: row[:bio],
#       intro: row[:intro],
#       email: "#{row[:profile].gsub(/\s+/, '')}@gmail.com",
#       password: "password"
#     )
#     puts "created: #{user.username}"
#     i += 1
#     avatar = URI.open("#{row[:avatar]}")
#     puts avatar
#     user.avatar.attach(io: avatar, filename: 'avatar.jpg', content_type: 'image/jpg')
#     user.save!
#   end

# i = 0
# sugg_profiles_csv = "./db/data/sugg_profiles.csv"
# CSV.foreach(sugg_profiles_csv, headers: :first_row, header_converters: :symbol, encoding: 'utf-8') do |row|
#   puts "----------------- ROW #{i} -----------------"
#   user = User.create!(
#     username: row[:profile],
#     intro: row[:intro],
#     bio: row[:bio],
#     email: "#{row[:profile].gsub(/\s+/, '')}@gmail.com",
#     password: "password"
#   )
#   puts "created: #{user.username}"
#   i += 1
#   avatar = URI.open("#{row[:avatar]}")
#   puts avatar
#   user.avatar.attach(io: avatar, filename: 'avatar.jpg', content_type: 'image/jpg')
#   user.save!
# end




# i = 0
# new_profiles_csv = "./db/data/new_profiles.csv"
# CSV.foreach(new_profiles_csv, headers: :first_row, header_converters: :symbol, encoding: 'utf-8') do |row|
#   puts "----------------- ROW #{i} -----------------"
#   user = User.create!(
#     username: row[:profile],
#     intro: row[:intro],
#     bio: row[:bio],
#     email: "#{row[:profile].gsub(/\s+/, '')}@gmail.com",
#     password: "password"
#   )
#   puts "created: #{user.username}"
#   i += 1
#   avatar = URI.open("#{row[:avatar]}")
#   puts avatar
#   user.avatar.attach(io: avatar, filename: 'avatar.jpg', content_type: 'image/jpg')
#   user.save!
# end





# list_csv = "./db/data/lists.csv"
# i = 0
# CSV.foreach(list_csv, headers: :first_row, header_converters: :symbol, encoding: 'utf-8') do |row|
#   puts "----------------- ROW #{i} -----------------"

#   p row[:profile]

#   list = List.new(
#     name: row[:list],
#     description: row[:info],
#   )

#   list.user = User.find_by(username: row[:profile])
#   list.save!

#   puts "created: #{list.name}"

#   i += 1
# end

# sugg_lists_csv = "./db/data/sugg_lists.csv"
# i = 0
# CSV.foreach(sugg_lists_csv, headers: :first_row, header_converters: :symbol, encoding: 'utf-8') do |row|
#   puts "----------------- ROW #{i} -----------------"
#   p row[:profile]
#   list = List.new(
#     name: row[:list],
#     description: row[:info],
#   )
#   list.user = User.find_by(username: row[:profile])
#   list.save!
#   puts "created: #{list.name}"
#   i += 1
# end

# new_lists_csv = "./db/data/new_lists.csv"
# i = 0
# CSV.foreach(new_lists_csv, headers: :first_row, header_converters: :symbol, encoding: 'utf-8') do |row|
#   puts "----------------- ROW #{i} -----------------"
#   p row[:profile]
#   list = List.new(
#     name: row[:list],
#     description: row[:info],
#   )
#   list.user = User.find_by(username: row[:profile])
#   list.save!
#   puts "created: #{list.name}"
#   i += 1
# end


# failed_lists_csv = "./db/data/failed_lists.csv"

# i = 0
# CSV.foreach(failed_lists_csv, headers: :first_row, header_converters: :symbol, encoding: 'utf-8') do |row|
#   puts "----------------- ROW #{i} -----------------"

#   p row[:profile]

#   list = List.new(
#     name: row[:list],
#     description: row[:info],
#   )

#   list.user = User.find_by(username: row[:profile])
#   list.save!

#   puts "created: #{list.name}"

#   i += 1
# end







# product_csv = "./db/data/products.csv"

# i = 0

# CSV.foreach(product_csv, headers: :first_row, header_converters: :symbol) do |row|
#   puts "row[:title]: #{row[:title]}"
#   puts "row[:description]: #{row[:description]}"
#   puts "row[:review]: #{row[:review]}"
#   puts "row[:price]: #{row[:price]}"
#   puts "row[:url]: #{row[:url]}"
#   puts "row[:logo]: #{row[:logo]}"
#   puts "row[:photos]: #{row[:photos]}"
#   puts "row[:code]: #{row[:code]}"
#   puts "row[:details]: #{row[:details]}"
#   puts "row[:profile]: #{row[:profile]}"
#   puts "row[:list]: #{row[:list]}"
# end

# CSV.foreach(product_csv, headers: :first_row, header_converters: :symbol, encoding: 'utf-8') do |row|
#   puts "----------------- ROW #{i} -----------------"
#   begin
#     puts row[:title]
#     puts row[:description]
#     puts row[:review]
#     puts row[:price]
#     puts row[:url]
#     puts row[:logo]
#     puts row[:photos]

#     product = Product.new(
#       title: row[:title],
#       description: row[:description],
#       review: row[:review],
#       price: row[:price].to_i,
#       url: row[:url],
#     )

#     logo = URI.open(row[:logo])
#     product.logo.attach(io: logo, filename: "logo.jpg", content_type: "image/jpg")

#     photo_urls = row[:photos].split("\n")
#     photo_urls.each do |url|
#       product_image = URI.open(url.strip)
#       product.photos.attach(io: product_image, filename: "product_image.jpg", content_type: "image/jpg")
#     end

#     # Only create and assign referral if code and details are present.
#     if row[:code].present? && row[:details].present?
#       referral = Referral.new(
#         code: row[:code],
#         details: row[:details],
#       )
#       product.referral = referral
#     end

#     product.user = User.find_by(username: row[:profile])
#     product.list = List.find_by(name: row[:list])
#     product.save!

#     puts "created: #{product.title}"
#     i += 1

#   rescue OpenURI::HTTPError => e
#     puts "HTTP Error: Failed to open a URL (either #{row[:logo]} or one of the images) due to #{e.message}. Skipping this product."
#     next
#   rescue Errno::ENOENT => e
#     puts "File Error: Failed to open a URL (either #{row[:logo]} or one of the images) due to #{e.message}. Skipping this product."
#     next
#   rescue => e
#     puts "General Error: An unexpected error occurred processing the product #{row[:title]} due to #{e.message}. Skipping this product."
#     next
#   end
# end



# tf_products_csv = './db/data/tf_products.csv'
# ah_products_csv = './db/data/ah_products.csv'
# jr_products_csv = './db/data/jr_products.csv'
# vr_products_csv = './db/data/vr_products.csv'
# failed_products_csv = './db/data/failed_products.csv'

# i = 0
# CSV.foreach(vr_products_csv, headers: :first_row, header_converters: :symbol, encoding: 'utf-8') do |row|
#   puts "----------------- ROW #{i} -----------------"
#   begin
#     puts row[:title]
#     puts row[:description]
#     puts row[:review]
#     puts row[:price]
#     puts row[:url]
#     puts row[:logo]
#     puts row[:photos]

#     product = Product.new(
#       title: row[:title],
#       description: row[:description],
#       review: row[:review],
#       price: row[:price].to_i,
#       url: row[:url],
#     )

#     logo = URI.open(row[:logo])
#     product.logo.attach(io: logo, filename: "logo.jpg", content_type: "image/jpg")

#     photo_urls = row[:photos].split("\n")
#     photo_urls.each do |url|
#       product_image = URI.open(url.strip)
#       product.photos.attach(io: product_image, filename: "product_image.jpg", content_type: "image/jpg")
#     end

#     # Only create and assign referral if code and details are present.
#     if row[:code].present? && row[:details].present?
#       referral = Referral.new(
#         code: row[:code],
#         details: row[:details],
#       )
#       product.referral = referral
#     end

#     product.user = User.find_by(username: row[:profile])
#     product.list = List.find_by(name: row[:list])
#     product.save!

#     puts "created: #{product.title}"
#     i += 1

#   rescue OpenURI::HTTPError => e
#     puts "HTTP Error: Failed to open a URL (either #{row[:logo]} or one of the images) due to #{e.message}. Skipping this product."
#     next
#   rescue Errno::ENOENT => e
#     puts "File Error: Failed to open a URL (either #{row[:logo]} or one of the images) due to #{e.message}. Skipping this product."
#     next
#   rescue => e
#     puts "General Error: An unexpected error occurred processing the product #{row[:title]} due to #{e.message}. Skipping this product."
#     next
#   end
# end


# i = 0

# CSV.foreach(tf_products_csv, headers: :first_row, header_converters: :symbol, encoding: 'utf-8') do |row|
#   puts "----------------- ROW #{i} -----------------"
#   begin
#     puts row[:title]
#     puts row[:description]
#     puts row[:review]
#     puts row[:price]
#     puts row[:url]
#     puts row[:logo]
#     puts row[:photos]

#     product = Product.new(
#       title: row[:title],
#       description: row[:description],
#       review: row[:review],
#       price: row[:price].to_i,
#       url: row[:url],
#     )

#     logo = URI.open(row[:logo])
#     product.logo.attach(io: logo, filename: "logo.jpg", content_type: "image/jpg")

#     photo_urls = row[:photos].split("\n")
#     photo_urls.each do |url|
#       product_image = URI.open(url.strip)
#       product.photos.attach(io: product_image, filename: "product_image.jpg", content_type: "image/jpg")
#     end

#     # Only create and assign referral if code and details are present.
#     if row[:code].present? && row[:details].present?
#       referral = Referral.new(
#         code: row[:code],
#         details: row[:details],
#       )
#       product.referral = referral
#     end

#     product.user = User.find_by(username: row[:profile])
#     product.list = List.find_by(name: row[:list])
#     product.save!

#     puts "created: #{product.title}"
#     i += 1

#   rescue OpenURI::HTTPError => e
#     puts "HTTP Error: Failed to open a URL (either #{row[:logo]} or one of the images) due to #{e.message}. Skipping this product."
#     next
#   rescue Errno::ENOENT => e
#     puts "File Error: Failed to open a URL (either #{row[:logo]} or one of the images) due to #{e.message}. Skipping this product."
#     next
#   rescue => e
#     puts "General Error: An unexpected error occurred processing the product #{row[:title]} due to #{e.message}. Skipping this product."
#     next
#   end
# end







# i = 0

# CSV.foreach(ah_products_csv, headers: :first_row, header_converters: :symbol, encoding: 'utf-8') do |row|
#   puts "----------------- ROW #{i} -----------------"
#   begin
#     puts row[:title]
#     puts row[:description]
#     puts row[:review]
#     puts row[:price]
#     puts row[:url]
#     puts row[:logo]
#     puts row[:photos]

#     product = Product.new(
#       title: row[:title],
#       description: row[:description],
#       review: row[:review],
#       price: row[:price].to_i,
#       url: row[:url],
#     )

#     logo = URI.open(row[:logo])
#     product.logo.attach(io: logo, filename: "logo.jpg", content_type: "image/jpg")

#     photo_urls = row[:photos].split("\n")
#     photo_urls.each do |url|
#       product_image = URI.open(url.strip)
#       product.photos.attach(io: product_image, filename: "product_image.jpg", content_type: "image/jpg")
#     end

#     # Only create and assign referral if code and details are present.
#     if row[:code].present? && row[:details].present?
#       referral = Referral.new(
#         code: row[:code],
#         details: row[:details],
#       )
#       product.referral = referral
#     end

#     product.user = User.find_by(username: row[:profile])
#     product.list = List.find_by(name: row[:list])
#     product.save!

#     puts "created: #{product.title}"
#     i += 1

#   rescue OpenURI::HTTPError => e
#     puts "HTTP Error: Failed to open a URL (either #{row[:logo]} or one of the images) due to #{e.message}. Skipping this product."
#     next
#   rescue Errno::ENOENT => e
#     puts "File Error: Failed to open a URL (either #{row[:logo]} or one of the images) due to #{e.message}. Skipping this product."
#     next
#   rescue => e
#     puts "General Error: An unexpected error occurred processing the product #{row[:title]} due to #{e.message}. Skipping this product."
#     next
#   end
# end


# i = 0

# CSV.foreach(jr_products_csv, headers: :first_row, header_converters: :symbol, encoding: 'utf-8') do |row|
#   puts "----------------- ROW #{i} -----------------"
#   begin
#     puts row[:title]
#     puts row[:description]
#     puts row[:review]
#     puts row[:price]
#     puts row[:url]
#     puts row[:logo]
#     puts row[:photos]

#     product = Product.new(
#       title: row[:title],
#       description: row[:description],
#       review: row[:review],
#       price: row[:price].to_i,
#       url: row[:url],
#     )

#     logo = URI.open(row[:logo])
#     product.logo.attach(io: logo, filename: "logo.jpg", content_type: "image/jpg")

#     photo_urls = row[:photos].split("\n")
#     photo_urls.each do |url|
#       product_image = URI.open(url.strip)
#       product.photos.attach(io: product_image, filename: "product_image.jpg", content_type: "image/jpg")
#     end

#     # Only create and assign referral if code and details are present.
#     if row[:code].present? && row[:details].present?
#       referral = Referral.new(
#         code: row[:code],
#         details: row[:details],
#       )
#       product.referral = referral
#     end

#     product.user = User.find_by(username: row[:profile])
#     product.list = List.find_by(name: row[:list])
#     product.save!

#     puts "created: #{product.title}"
#     i += 1

#   rescue OpenURI::HTTPError => e
#     puts "HTTP Error: Failed to open a URL (either #{row[:logo]} or one of the images) due to #{e.message}. Skipping this product."
#     next
#   rescue Errno::ENOENT => e
#     puts "File Error: Failed to open a URL (either #{row[:logo]} or one of the images) due to #{e.message}. Skipping this product."
#     next
#   rescue => e
#     puts "General Error: An unexpected error occurred processing the product #{row[:title]} due to #{e.message}. Skipping this product."
#     next
#   end
# end
#
#
# i = 0
#
# CSV.foreach(failed_products_csv, headers: :first_row, header_converters: :symbol, encoding: 'utf-8') do |row|
  # puts "----------------- ROW #{i} -----------------"
  # begin
    # puts row[:title]
    # puts row[:description]
    # puts row[:review]
    # puts row[:price]
    # puts row[:url]
    # puts row[:logo]
    # puts row[:photos]
#
    # product = Product.new(
      # title: row[:title],
      # description: row[:description],
      # review: row[:review],
      # price: row[:price].to_i,
      # url: row[:url],
    # )
#
    # logo = URI.open(row[:logo])
    # product.logo.attach(io: logo, filename: "logo.jpg", content_type: "image/jpg")
#
    # photo_urls = row[:photos].split("\n")
    # photo_urls.each do |url|
      # product_image = URI.open(url.strip)
      # product.photos.attach(io: product_image, filename: "product_image.jpg", content_type: "image/jpg")
    # end
#
    # Only create and assign referral if code and details are present.
    # if row[:code].present? && row[:details].present?
      # referral = Referral.new(
        # code: row[:code],
        # details: row[:details],
      # )
      # product.referral = referral
    # end
#
    # product.user = User.find_by(username: row[:profile])
    # product.list = List.find_by(name: row[:list])
    # product.save!
#
    # puts "created: #{product.title}"
    # i += 1
#
  # rescue OpenURI::HTTPError => e
    # puts "HTTP Error: Failed to open a URL (either #{row[:logo]} or one of the images) due to #{e.message}. Skipping this product."
    # next
  # rescue Errno::ENOENT => e
    # puts "File Error: Failed to open a URL (either #{row[:logo]} or one of the images) due to #{e.message}. Skipping this product."
    # next
  # rescue => e
    # puts "General Error: An unexpected error occurred processing the product #{row[:title]} due to #{e.message}. Skipping this product."
    # next
  # end
# end
#


new_products_csv = "./db/data/new_products.csv"
i = 0
CSV.foreach(new_products_csv, headers: :first_row, header_converters: :symbol, encoding: 'utf-8') do |row|
  i += 1
  puts "----------------- ROW #{i} -----------------"
  begin
    puts row[:title]
    puts row[:description]
    puts row[:review]
    puts row[:price]
    puts row[:url]
    puts row[:logo]
    puts row[:photos]

    product = Product.new(
      title: row[:title],
      description: row[:description],
      review: row[:review],
      price: row[:price].to_i,
      url: row[:url],
      subscription_type: row[:subscription]
    )

    logo = URI.open(row[:logo])
    product.logo.attach(io: logo, filename: "logo.jpg", content_type: "image/jpg")

    photo_urls = row[:photos].split("\n")
    photo_urls.each do |url|
      product_image = URI.open(url.strip)
      product.photos.attach(io: product_image, filename: "product_image.jpg", content_type: "image/jpg")
    end

    # Only create and assign referral if code and details are present.
    if row[:code].present? && row[:details].present?
      referral = Referral.new(
        code: row[:code],
        details: row[:details],
      )
      product.referral = referral
    end

    product.user = User.find_by(username: row[:profile])
    product.list = List.find_by(name: row[:list])
    product.save!

    puts "created: #{product.title}"
    i += 1

  rescue OpenURI::HTTPError => e
    puts "HTTP Error: Failed to open a URL (either #{row[:logo]} or one of the images) due to #{e.message}. Skipping this product."
    next
  rescue Errno::ENOENT => e
    puts "File Error: Failed to open a URL (either #{row[:logo]} or one of the images) due to #{e.message}. Skipping this product."
    next
  rescue => e
    puts "General Error: An unexpected error occurred processing the product #{row[:title]} due to #{e.message}. Skipping this product."
    next
  end
end
