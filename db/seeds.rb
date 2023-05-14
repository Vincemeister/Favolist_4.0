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
  puts "Created #{user.username}"

  list = List.create!(
    name: "#{user.username}'s List",
    description: "This is #{user.username}'s list",
    user: user
  )

  puts "Adding products to #{user.username}'s List"

  3.times do
    Product.create!(
      title: Faker::Commerce.product_name,
      price: Faker::Commerce.price,
      review: Faker::Lorem.paragraph,
      description: Faker::Lorem.paragraph,
      list: list,
      url: Faker::Internet.url
    )
  end
end
