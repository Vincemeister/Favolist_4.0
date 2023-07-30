require "csv"
require "open-uri"


puts "destroying all users"
User.destroy_all

people_csv = "./db/data/people.csv"
i = 0
CSV.foreach(people_csv, headers: :first_row, header_converters: :symbol) do |row|
  puts "----------------- ROW #{i} -----------------"
  user = User.create!(
    username: row[:profile],
    bio: row[:bio],
    email: "#{row[:profile].gsub(/\s+/, '')}@gmail.com",
    password: "password"
  )
  puts "created: #{user.username}"
  i += 1
  avatar = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1684039630/Favolist%204.0/owl.jpg")
  puts avatar
  user.avatar.attach(io: avatar, filename: 'avatar.jpg', content_type: 'image/jpg')
  user.save!
end



list_csv = "./db/data/lists.csv"

i = 0
CSV.foreach(list_csv, headers: :first_row, header_converters: :symbol) do |row|
  puts "----------------- ROW #{i} -----------------"

  p row[:profile]

  list = List.new(
    name: row[:list],
    description: row[:info],
  )

  list.user = User.find_by(username: row[:profile])
  list.save!

  puts "created: #{list.name}"

  i += 1
end



Product.last(5).each do |product|
  puts "destroying #{product.title}"
  product.destroy
end

product_csv = "./db/data/products.csv"

i = 0

CSV.foreach(product_csv, headers: :first_row, header_converters: :symbol) do |row|
  puts "row[:title]: #{row[:title]}"
  puts "row[:description]: #{row[:description]}"
  puts "row[:review]: #{row[:review]}"
  puts "row[:price]: #{row[:price]}"
  puts "row[:url]: #{row[:url]}"
  puts "row[:logo]: #{row[:logo]}"
  puts "row[:photo_1]: #{row[:photo_1]}"
  puts "row[:code]: #{row[:code]}"
  puts "row[:details]: #{row[:details]}"
  puts "row[:profile]: #{row[:profile]}"
  puts "row[:list]: #{row[:list]}"
end

CSV.foreach(product_csv, headers: :first_row, header_converters: :symbol) do |row|
  puts "----------------- ROW #{i} -----------------"

  puts row[:title]
  puts row[:description]
  puts row[:review]
  puts row[:price]
  puts row[:url]
  puts row[:logo]
  puts row[:photo_1]

  product = Product.new(
    title: row[:title],
    description: row[:description],
    review: row[:review],
    price: row[:price].to_i,
    url: row[:url],
  )

  logo = URI.open(row[:logo])
  product.logo.attach(io: logo, filename: "logo.jpg", content_type: "image/jpg")



  product_image = URI.open(row[:photo_1])
  product.photos.attach(io: product_image, filename: "product_image.jpg", content_type: "image/jpg")



  referral = Referral.new(
    code: row[:code],
    details: row[:details],
  )

  product.referral = referral

  product.user = User.find_by(username: row[:profile])
  product.list = List.find_by(name: row[:list])
  product.save!

  puts "created: #{product.title}"

  i += 1
end
