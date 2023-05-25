# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
require "open-uri"

puts "Clearing database..."
User.destroy_all

#----------------MAIN USERS---------------------------------------------------------------------------------------------
puts "Creating main users..."
vincent = User.create!(
  username: "Vincent",
  email: "vr@gmail.com",
  password: "password",
  bio: Faker::Lorem.paragraph(sentence_count: 10)
)
avatar = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1684039630/Favolist%204.0/owl.jpg")
vincent.avatar.attach(io: avatar, filename: 'avatar.jpg', content_type: 'image/jpg')
vincent.save!
#----------------RANDOM USERS-------------------------------------------------------------------------------------------
puts "Creating random users with lists and products..."
3.times do
  puts "Creating random user..."
  user = User.create!(
    username: Faker::Internet.username,
    email: Faker::Internet.email,
    password: "password",
    bio: Faker::Lorem.paragraph(sentence_count: 10)
  )
  avatar = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1684039630/Favolist%204.0/owl.jpg")
  user.avatar.attach(io: avatar, filename: 'avatar.jpg', content_type: 'image/jpg')
  user.save!
  puts "Created #{user.username}"
  list = List.create!(
    name: "#{user.username}'s List",
    description: "This is #{user.username}'s list",
    user: user,
  )
  2.times do
    product = Product.create!(
      title: Faker::Commerce.product_name,
      price: Faker::Commerce.price,
      review: Faker::Lorem.paragraph,
      description: Faker::Lorem.paragraph,
      list: list,
      url: Faker::Internet.url
    )
    product_image = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1684045499/Favolist%204.0/oura_pjds07.jpg")
    logo = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1684038909/Favolist%204.0/oura_logo_4.jpg")
    product.photos.attach(io: product_image, filename: "product_image.jpg", content_type: "image/jpg")
    product.logo.attach(io: logo, filename: "logo.jpg", content_type: "image/jpg")
    product.save!
  end
end
#----------------ESTABLISHING FOLLOW RELATIONSHIPS----------------------------------------------------------------------
puts "Establishing Tims  random followships..."
User.all.reject { |user| user.id == vincent.id }.each do |user|
  Follow.create(follower_id: user.id, followed_id: vincent.id)
end
User.all.reject { |user| user.id == vincent.id }.each do |user|
  Follow.create(follower_id: vincent.id, followed_id: user.id)
end
#----------------FITNESS EQUIPMENT--------------------------------------------------------------------------------------
puts "Creating fitness equipment list for Vincent..."

  fitness_equipment = List.create!(
    name: "Vincent's List",
    description: "This is Vincent's list",
    user: vincent,
  )
#-----------------------------------------------------------------------------------------------------------------------
#---------------Oura ring-------------------------------------------------------
puts "Creating product for Vincent"
product = Product.create!(
  title: "Oura Ring 3.0",
  price: 299,
  review: "I've been using the Oura Ring for a few weeks now, and I have to say, I'm impressed.  The device is incredibly accurate when it comes to tracking my sleep patterns, and I've been able to use the insights it provides to make some changes to my sleep routine that have really helped me feel more rested and energized during the day. I also appreciate the fact that the Oura Ring is so easy to wear and forget about. Unlike other fitness trackers or smartwatches, I hardly even notice that I'm wearing it, which makes it much more convenient to use on a daily basis.

  While I have noticed a few minor issues with the accuracy of the activity tracking (particularly when it comes to tracking specific exercises), I still find the overall insights and data provided by the device to be incredibly valuable.

  Overall, I would definitely recommend the Oura Ring to anyone who is looking for a more comprehensive and accurate way to track their sleep and overall health.",
  description: "Each style has identical technical and hardware capabilities.

  Water resistant up to 100 m (more than 328 ft.)
  Lighter than a conventional ring (4 to 6 grams)
  Titanium: durable and wearable
  Includes size-specific charger and USB-C cable
  With daily wear, the ring may develop scratches

  Ring sensors should be on the palm side of your finger for the most accurate reading. To help ensure optimal positioning, Oura Horizon has a sleek, uninterrupted circular design with a pill-shaped dimple on the bottom, and Oura Heritage has a classic, plateau design with a flat surface on top.",
  list: fitness_equipment,
  url: "https://ouraring.com/product/heritage-silver"
)
product_image = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1684045499/Favolist%204.0/oura_pjds07.jpg")
logo = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1684038909/Favolist%204.0/oura_logo_4.jpg")
product.photos.attach(io: product_image, filename: "product_image.jpg", content_type: "image/jpg")
product.logo.attach(io: logo, filename: "logo.jpg", content_type: "image/jpg")
#-------------Peloton Row-------------------------------------------------------
puts "Creating product for Vincent"
product = Product.create!(
  title: "Peloton Row",
  price: 3195,
  review: "Peloton Row brings personalized form features to rowing to help you learn and master your stroke. Form features like Form Assist indicate how to improve your stroke in class in real time, as well as a detailed post-class breakdown so you can hit the Row harder next time. And with features that allow you to personalize your target metrics, you become an expert at the level and pace that feels good for you. You get all your cardio and strength in one shot, while protecting your joints and ligaments in a high-intensity, low-impact way. Fun fact: you work 86% of your muscles in only 15 minutes.",
  description: "Form-specific features and metrics that continually help you improve your form, whether you’re new to rowing or a pro
  Workouts led by expert Peloton instructors that will keep you motivated and challenged
  Real time readout of stroke rate, pace, output, and distance
  Compact footprint that stows against your wall for easy storage
  Comfortable ergonomic seat and smooth, nearly silent rowing experience",
  list: fitness_equipment,
  url: "https://www.onepeloton.com/row"
)
product_image = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1678942754/favolist/app%20assets/product%20images/tim%20ferris/Peloton%20Row/Peloton_Row_vhemkl.png")
logo = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1678942753/favolist/app%20assets/product%20images/tim%20ferris/Peloton%20Row/Peloton_Row-logo_l7zklg.png")
product.photos.attach(io: product_image, filename: "product_image.jpg", content_type: "image/jpg")
product.logo.attach(io: logo, filename: "logo.jpg", content_type: "image/jpg")
product.save!

product_image = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1685023405/Favolist%204.0/products/peloton%20row/peloton_image_3_kf69qj.webp")
product.photos.attach(io: product_image, filename: "product_image.jpg", content_type: "image/jpg")
product_image = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1685023402/Favolist%204.0/products/peloton%20row/peloton_image_2_htsop0.jpg")
product.photos.attach(io: product_image, filename: "product_image.jpg", content_type: "image/jpg")
product.save!
puts "Adding referral to #{product.title}"
referral = Referral.new(
  code: "https://www.onepeloton.com/row",
  details: "Right now is the perfect time to get rowing with Peloton Row. Peloton Row offers a variety of classes for all levels plus game-changing features that help you get rowing or advance the rowing you can already do. Explore Peloton Row at OnePeloton.com/Row."
)
referral.product = product
referral.save!
#-------------Gen 4 Theragun PRO------------------------------------------------
puts "Creating product for Vincent"
product = Product.create!(
  title: "Gen 4 Theragun PRO",
  price: 429,
  review: "Theragun is my go-to solution for recovery and restoration. It’s a famous, handheld percussive therapy device that releases your deepest muscle tension. I own two Theraguns, and my girlfriend and I use them every day after workouts and before bed. The all-new Gen 4 Theragun is easy to use and has a proprietary brushless motor that’s surprisingly quiet—about as quiet as an electric toothbrush.",
  description: "The deep muscle treatment pros trust with the durability and features they rely on. Enhance muscle recovery, release stress and tension, and soothe discomfort with the smart percussive therapy device in a league of its own. We stand by PRO's professional-grade durability with an industry-leading 2-year warranty.",
  list: fitness_equipment,
  url: "Theragun.com/Tim"
)
product_image = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1678610984/favolist/app%20assets/product%20images/tim%20ferris/theragun/Theragun-PRO-Carousel-06_luceb2.webp")
logo = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1678610973/favolist/app%20assets/product%20images/tim%20ferris/theragun/Therabody_Logo_ozrvok.svg")
product.photos.attach(io: product_image, filename: "product_image.jpg", content_type: "image/jpg")
product.logo.attach(io: logo, filename: "logo.jpg", content_type: "image/jpg")
product.save!
puts "Adding referral to #{product.title}"
referral = Referral.new(
  code: "Theragun.com/Tim",
  details: "Go to Theragun.com/Tim right now and get your Gen 4 Theragun today, starting at only $199."
)
referral.product = product
referral.save!
#-------------Nayoya Gymnastic Rings--------------------------------------------
puts "Creating product for Vincent"
product = Product.create!(
  title: "NAYOYA Gymnastic Rings",
  price: 34.97,
  review: "These are super portable (easily fit in a small backpack) and incredibly durable for the price. I’m using them for mostly dips and muscle-up progressions. The Nayoya allow me to leave the rings outdoors. BUT: If you’re going to travel without chalk, I highly suggest wooden rings.",
  description: "BEST RATED GYM RINGS ON THE MARKET; Includes 2 Gymnastic Rings with straps and adjusting buckles; The rings are made of textured, grippable PC Plastic (to reduce slippage associated with sweaty hands)which is stronger, more durable and of higher quality material then ABS plastic rings and are capable of supporting up to 2,000 lbs making them the best quality gymnastics rings on the market
  TAKES 5 MINUTES TO SET UP, USE AND ADJUST providing you with a great home gym substitute
  UNLIMITED BODY WEIGHT EXERCISES; Ring training is a very mobile and versatile way to engage your muscles and core with exercises such as pullups, pushups, dips, rows, muscle ups for a functional and varied free range of movement; Great for kids to use in the backyard and for avid exercise lovers to use in the gym or anywhere they can safely hang them
  THE PROPER WAY TO INSTALL THE STRAPS is to go from underneath the buckle and slide the straps in the same direction the arrow on the buckle is pointing to; Note where the arrow points on the buckle for proper installation; Proper installation will ensure that your straps will be secure and non slip
  DEVELOP the aesthetically pleasing physique of a gymnast while strengthening your core, tendons, joints and accessory muscles",
  list: fitness_equipment,
  url: "https://www.amazon.com/Gymnastic-Strength-Muscular-Bodyweight-Training/dp/B009RA6C1K?tag=fliist-20&geniuslink=true"
)
product_image = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1678704276/favolist/app%20assets/product%20images/tim%20ferris/Gymnastic%20Rings/Gymnastic_Rings_e9fjpn.jpg")
logo = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1678704276/favolist/app%20assets/product%20images/tim%20ferris/Gymnastic%20Rings/Gymnastic_Rings-logo_jw48ny.jpg")
product.photos.attach(io: product_image, filename: "product_image.jpg", content_type: "image/jpg")
product.logo.attach(io: logo, filename: "logo.jpg", content_type: "image/jpg")
product.save!
#-------------FEZiBO Balance Board----------------------------------------------
puts "Creating product for Vincent"
product = Product.create!(
  title: "FEZiBO Balance Board",
  price: 59.99,
  review: "I will spend 30 to 60 seconds in different ways positioning my foot and improving my stability in the lower leg. Super easy to travel with. I've had a huge ROI on very little exercise while doing that.",
  description: "Standing in place all day has its limitations, and sitting in place isn't even an option anymore. Standing desks are becoming more and more popular these days; many studies have shown it can improve your overall health. FEZIBO Balance Board is ideal for holding balance exercises and creates low-impact rocker movement to keep your mind and body engaged while you’re working. It not only helps relieve muscle stress and pain in the back, core, legs, and ankles while standing, but it’s also a whole lot more fun.",
  list: fitness_equipment,
  url: "https://www.fezibo.com/products/fezibo-standing-desk-mat-anti-fatigue-bar"
)
product_image = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1678703983/favolist/app%20assets/product%20images/tim%20ferris/Anti%20Fatigue%20Mat/Anti_Fatigue_Mat_wsrrvh.jpg")
logo = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1678704724/favolist/app%20assets/product%20images/tim%20ferris/Anti%20Fatigue%20Mat/FEZIBO_logo_gsogww.png")
product.photos.attach(io: product_image, filename: "product_image.jpg", content_type: "image/jpg")
product.logo.attach(io: logo, filename: "logo.jpg", content_type: "image/jpg")
product.save!
#-------------PSO-RITE Psoas Muscle Release and Deep Tissue Massage Tool--------
puts "Creating product for Vincent"
product = Product.create!(
  title: "PSO-RITE Psoas Muscle Release and Deep Tissue Massage Tool",
  price: 79.95,
  review: "PSO-RITE for psoas muscle release. Recommended by multiple people in this Twitter thread on self-release. This is the easier to use of these two grouped bullets, but it’s not as surgically precise as the Hip Hook.",
  description: "SIMPLE, AGGRESSIVE, UNMATCHED: The PSO-Rite is the most revolutionary self-care mobility massage and muscle release tool of our time. The psoas complex (hip flexors) are considered to be the soul of our body. They regulate our fight or flight response, support our digestive organs, regulate our breathing, and aid in pumping blood and lymph through our body.
  YOUR MASSAGE THERAPIST IN YOUR HANDS: Designed to be the shape of a therapist’s hand and the hardness of an elbow, you now have your own in-house therapist to correct pain and dysfunction in the hip region any time you want. Pressure and only pressure is what releases muscle tissue in the human body. The PSO-Rite psoas muscle release tool was designed to provide relief on the deepest level for any age, size, and shaped individual out there.
  VERSATILE AND PRECISE: Specifically designed to use one peak at a time on each psoas muscle, the PSO-Rite deep tissue massage tool is just as effective at releasing tightness in nearly every muscle of the body. Use it on your hamstrings, thigh, inner thigh, calf, glutes, lower back, upper back, triceps, biceps, and chest. YOU ARE THE PRESSURE!
  DEEP-TISSUE MASSAGE TOOL ALWAYS WITH YOU: Available anytime you need it, anywhere you go. Use your PSO-Rite in your gym sessions, sports trainings, in the office or comfortably at home.
  The recommended amount of time to stay in any given position using the PSO products is 5 – 60 seconds. Always consult a doctor before using a massage apparatus.",
  list: fitness_equipment,
  url: "https://www.amazon.com/PSO-RITE-Psoas-Release-Personal-Massager/dp/B07DPCWV8Z/"
)
product_image = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1678704430/favolist/app%20assets/product%20images/tim%20ferris/%E2%80%8BPSO-RITE/PSO-RITE_f8aup4.jpg")
logo = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1678704430/favolist/app%20assets/product%20images/tim%20ferris/%E2%80%8BPSO-RITE/PSO-RITE_-_logo_qxpxwe.png")
product.photos.attach(io: product_image, filename: "product_image.jpg", content_type: "image/jpg")
product.logo.attach(io: logo, filename: "logo.jpg", content_type: "image/jpg")
product.save!
#-------------Rubz Ball---------------------------------------------------------
puts "Creating product for Vincent"
product = Product.create!(
  title: "Rubz Ball",
  price: 5.88,
  review: "Meet one of my favorite travel partners, which can be thought of as a golf ball that won’t shoot across the floor when stepped on. Roll this uniquely designed ball under your feet (my go-to area) or over any sore or tired muscle to reduce tension. It’s small enough to fit in a pocket and easy to manipulate.",
  description: "Massage: Rubz Green ball massages trouble spots on hands, feet, and other muscles to reduce tension, relax muscles and increase circulation. The ball can be used to relieve Plantar Fasciitis symptoms, break up fascia, or relieve tight and sore muscles.
  Texture: Strategically placed, flat spikes stimulate muscles without creating sharp pain from pointed spike massage balls. Apply desired pressure to relieve tension without exceeding your comfort zone.
  Usage: Use Rubz anywhere: in your home or at the office, gym, health club, and more. Doctor recommendations support Rubz to relieve Plantar Faciitis. Great for runners, working long hours on your feet, athletes and more. Can also be used as a stress ball.
  Density: The Rubz ball is designed with a dense rubber material is firm to combat deep trigger points and break up fascia tissue. The rubber is flexible for adjusting pressure without damaging flooring.
  Additional Features: Made in the USA. Great to use with other Rubz Products: Rubz Foot Roller and Rubz Full Body Massage.",
  list: fitness_equipment,
  url: "https://www.amazon.com/Due-North-Massage-Plantar-Fasciitus/dp/B002QEY6NK"
)
product_image = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1678704445/favolist/app%20assets/product%20images/tim%20ferris/Rubz%20ball/Rubz_ball_r0vgiv.jpg")
logo = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1678704491/favolist/app%20assets/product%20images/tim%20ferris/Rubz%20ball/rubz_logo_web_fvil8i.png")
product.photos.attach(io: product_image, filename: "product_image.jpg", content_type: "image/jpg")
product.logo.attach(io: logo, filename: "logo.jpg", content_type: "image/jpg")
product.save!
#-------------Vuori Sunday Performance Jogger-----------------------------------
puts "Creating product for Vincent"
product = Product.create!(
  title: "Vuori Sunday Performance Jogger",
  price: 95,
  review: "Vuori clothing is a new and fresh perspective on performance apparel. Perfect if you are sick and tired of traditional, old workout gear. Everything is designed for maximum comfort and versatility so that you look and feel as good in everyday life as you do working out.",
  description: "Vuori is built to move and sweat in yet designed with a West Coast aesthetic that transitions effortlessly into everyday life. Breaking down the boundaries of traditional activewear, we are a new perspective on performance apparel.",
  list: fitness_equipment,
  url: "https://vuoriclothing.com/pages/pod_timferriss_sp23"
)
product_image = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1678942913/favolist/app%20assets/product%20images/tim%20ferris/Vuori/Vuori_yczqle.jpg")
logo = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1678942912/favolist/app%20assets/product%20images/tim%20ferris/Vuori/Vuori-logo_gw8wtl.jpg")
product.photos.attach(io: product_image, filename: "product_image.jpg", content_type: "image/jpg")
product.logo.attach(io: logo, filename: "logo.jpg", content_type: "image/jpg")
product.save!
puts "Adding referral to #{product.title}"
referral = Referral.new(
  code: "https://vuoriclothing.com/pages/pod_timferriss_sp23",
  details: "Get yourself some of the most comfortable and versatile clothing on the planet at VuoriClothing.com/Tim. Not only will you receive 20% off your first purchase, but you’ll also enjoy free shipping on any US orders over $75 and free returns."
)
referral.product = product
referral.save!
#-----------------------------------------------------------------------------------------------------------------------
puts "Fitness Equipment list complete!"
#----------------Health Hacks & Supplements-----------------------------------------------------------------------------
puts "Creating Health Hacks and Supplements list for Vincent..."

  fitness_equipment = List.create!(
    name: "Health Hacks and Supplements",
    description: "This is Vincent's list",
    user: vincent,
  )
