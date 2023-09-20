require "csv"
require "open-uri"

puts "Creating 30 users..."

10.times do
  puts "Creating random user..."
  user = User.create!(
    username: Faker::Internet.unique.username,  # Unique to avoid duplicate usernames
    email: Faker::Internet.unique.email,        # Unique to avoid duplicate emails
    password: "password",
    bio: Faker::Lorem.paragraph(sentence_count: 2)
  )

  # Fetch the profile picture from the given URL and attach to user avatar
  avatar = URI.open("https://beforeigosolutions.com/wp-content/uploads/2021/12/dummy-profile-pic-300x300-1.png")
  user.avatar.attach(io: avatar, filename: 'avatar.png', content_type: 'image/png')

  user.save!
  puts "Created #{user.username}"
end

# To reset the unique generators in Faker if you need to run the seed multiple times.
Faker::Internet.unique.clear
