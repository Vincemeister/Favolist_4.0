require "csv"

People.last(5).each do |person|
  person.destroy
  puts "check that people are destroyed"
  puts People.last
end

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
  puts user
  i += 1
  break if i > 5
end

User.last(5).each do |user|
  puts "----------------- USER -----------------"
  puts user
  puts user.username
  puts user.bio
end


List.last(5).each do |list|
  list.destroy
  puts "check that lists are destroyed"
  puts List.last
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

  puts list
  puts list.name
  puts list.description
  puts list.user.username

  i += 1
  break if i > 5
end


