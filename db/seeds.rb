# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

puts "Creating Vincent and 5 users..."

vincent = User.create!(
  username: "vincent",
  email: "vincent@gmail.com",
  password: "password",
)
avatar_vincent = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1678342734/avatars/Linkedin_3_asp0qi.jpg")
vincent.avatar.attach(io: avatar_vincent, filename: 'vinc.jpg', content_type: 'image/jpg')
vincent.save!

puts "Adding list for Vincent"

  list = List.create!(
    name: "Vincent's List",
    description: "This is Vincent's list",
    user: vincent,
  )

puts "Adding products to Vincent's List"

3.times do
  Product.create!(
    title: Faker::Commerce.product_name,
    price: Faker::Commerce.price,
    review: Faker::Lorem.paragraph,
    description: Faker::Lorem.paragraph,
    list: list,
    url: Faker::Internet.url,
  )
end

puts "Creating 5 users and add one list and 3 products per user and list"

5.times do
  user = User.create!(
    username: Faker::Internet.username,
    email: Faker::Internet.email,
    password: "password",
  )
  user.avatar.attach(io: avatar_vincent, filename: 'vinc.jpg', content_type: 'image/jpg')
  user.save!
  puts "Created #{user.username}"

  list = List.create!(
    name: "#{user.username}'s List",
    description: "This is #{user.username}'s list",
    user: user
  )

  puts "Adding products to #{user.username}'s List"

  3.times do
    product = Product.create!(
      title: Faker::Commerce.product_name,
      price: Faker::Commerce.price,
      review: Faker::Lorem.paragraph,
      description: Faker::Lorem.paragraph,
      list: list,
      url: Faker::Internet.url
    )
    product_image = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1678956470/favolist/app%20assets/product%20images/more%20products/https___s3.amazonaws.com_ouraring.com_images_product_simple_pdp-img-carousel-silver-03-heritage_2x_nmfat3.webp"),
    logo = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1678956487/favolist/app%20assets/product%20images/more%20products/7B24ADCF-7925-4513-A32B-B81476285567_1_105_c_ux0tuv.jpg")
    product.photos.attach(io: product_image, filename: "image.jpg", content_type: "image/jpg")
    product.logo.attach(io: logo, filename: "image.jpg", content_type: "image/jpg")
    product.save!
  end
end
