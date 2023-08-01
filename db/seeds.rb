# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
require "open-uri"
require "csv"


# 30.times do
#   puts "Creating random user..."
#   user = User.create!(
#     username: Faker::Internet.username,
#     email: Faker::Internet.email,
#     password: "password",
#     bio: Faker::Lorem.paragraph(sentence_count: 10)
#   )
#   avatar = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1684039630/Favolist%204.0/owl.jpg")
#   user.avatar.attach(io: avatar, filename: 'avatar.jpg', content_type: 'image/jpg')
#   user.save!
#   puts "Created #{user.username}"
# end

# require_relative 'data_loader'



# puts "Clearing database..."
# User.destroy_all
puts "Removign amazon logo..."


#----------------AMAZON LOGO--------------------------------------------------------------------------------------------


file_path = "https://res.cloudinary.com/dncij7vr6/image/upload/v1686825737/Favolist%204.0/app%20assets/amazon-logo-transparent_lhlhxu.png"
file = URI.open(file_path)
amazon_logo = ActiveStorage::Blob.create_and_upload!(io: file, filename: 'amazon_logo.png', content_type: 'image/png')
puts amazon_logo



#----------------MAIN USERS---------------------------------------------------------------------------------------------
puts "Creating main users..."
vincent = User.create!(
  username: "Tim Ferriss",
  email: "vr@gmail.com",
  password: "password",
  bio: Faker::Lorem.paragraph(sentence_count: 10)
)
avatar = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1684039630/Favolist%204.0/owl.jpg")
vincent.avatar.attach(io: avatar, filename: 'avatar.jpg', content_type: 'image/jpg')
vincent.save!
#----------------RANDOM USERS-------------------------------------------------------------------------------------------
puts "Creating random users with lists and products..."
2.times do
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
  1.times do
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
#----------------MORE RANDOM USERS WITHOUT PRODUCTS---------------------------------------------------------------------
puts "Creating random users without products..."
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
end
#----------------ESTABLISHING FOLLOW RELATIONSHIPS----------------------------------------------------------------------
puts "Establishing Tims  random followships..."
User.all.reject { |user| user.id == vincent.id }.each do |user|
  Follow.create(follower_id: user.id, followed_id: vincent.id)
  Follow.create(follower_id: vincent.id, followed_id: user.id)
end
#-----------------------------------------------------------------------------------------------------------------------
puts "Creating some more users without follow relationships..."
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
end
#----------------FITNESS EQUIPMENT--------------------------------------------------------------------------------------
puts "Creating fitness equipment list for Vincent..."

  fitness_equipment = List.create!(
    name: "Vincent's List",
    description: "This is Vincent's list",
    user: vincent,
  )
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
logo = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1685246787/Favolist%204.0/products/theragun/therabody_logo_pbuoyw.png")
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
#-----------------------------------------------------------------------------------------------------------------------
#----------------Health Hacks & Supplements-----------------------------------------------------------------------------
puts "Creating Health Hacks and Supplements list for Vincent..."
  health_hacks = List.create!(
    name: "Health Hacks and Supplements",
    description: "This is Vincent's list",
    user: vincent,
  )
#-------------Athletic Greens---------------------------------------------------
puts "Creating product for Vincent"
product = Product.create!(
  title: "Athletic Greens AG1 Pouch",
  price: 99,
  review: "I get asked all the time, “If you could only use one supplement, what would it be?” My answer is usually Athletic Greens, my all-in-one nutritional insurance. I recommended it in The 4-Hour Body in 2010 and did not get paid to do so. I do my best with nutrient-dense meals, of course, but AG further covers my bases with vitamins, minerals, and whole-food-sourced micronutrients that support gut health and the immune system.
  ",
  description: "75 high-quality vitamins, minerals, and whole-food sourced nutrients
  Comprehensive nutrition in one simple scoop
  Build a healthy daily habit in one minute per day
  Promotes gut health, supports immunity, boosts energy, and more*
  Backed by our Scientific Advisory Board",
  list: health_hacks,
  url: "https://athleticgreens.com/en"
)
product_image = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1678942468/favolist/app%20assets/product%20images/tim%20ferris/Athletic%20Greens/Athletic_Greens_jhsubj.jpg")
logo = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1678942468/favolist/app%20assets/product%20images/tim%20ferris/Athletic%20Greens/Athletic_Greens-logo_h00w1z.png")
product.photos.attach(io: product_image, filename: "product_image.jpg", content_type: "image/jpg")
product.logo.attach(io: logo, filename: "logo.jpg", content_type: "image/jpg")
product.save!
puts "Adding referral to #{product.title}"
referral = Referral.new(
  code: "AthleticGreens.com/Tim",
  details: "Visit AthleticGreens.com/Tim to claim this special offer today and receive the free Vitamin D Liquid Formula (and five free travel packs) with your first subscription purchase! That’s up to a one-year supply of Vitamin D as added value when you try their delicious and comprehensive all-in-one daily greens product."
)
referral.product = product
referral.save!
#-------------LMNT--------------------------------------------------------------
puts "Creating product for Vincent"
product = Product.create!(
  title: "LMNT Recharge",
  price: 45,
  review: " I’ve stocked up on boxes and boxes of LMNT, and I usually use 1–2 packs per day to add electrolytes to prevent dehydration symptoms like headaches, muscle cramps, and fatigue. I add electrolytes for many reasons: because I over-hydrate compulsively while stuck at a laptop (which dilutes electrolytes and leads me to feel tired), because I’m on a low-carb diet, because I’ve lost electrolytes through exercise, dry winter climates, etc. It’s simply cheap hydration insurance that tastes great. Each serving of LMNT delivers a meaningful dose of electrolytes without the garbage—no sugar, no artificial ingredients, no coloring, no junk. My favorite flavor is Citrus Salt, which, as a side note, you can use to make a kick-ass, no-sugar margarita. ",
  description: "A tasty electrolyte drink mix that is formulated to help anyone with their electrolyte needs and is perfectly suited to folks following a keto, low-carb, or paleo diet.",
  list: health_hacks,
  url: "https://drinklmnt.com/products/lmnt-recharge-electrolyte-drink?rfsn=4170580.a8d43d&utm_medium=sponsor&utm_source=timferriss&utm_campaign=agwp&utm_content=&utm_term=&_gl=1*aoyrap*_ga*OTM2NzQ0ODcwLjE2Nzg2OTg5OTY.*_ga_BKZV7MVXM7*MTY3ODY5ODk5Ni4xLjEuMTY3ODY5ODk5Ni4wLjAuMA..&variant=16358367199266"
)
product_image = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1678704381/favolist/app%20assets/product%20images/tim%20ferris/%E2%80%8BLMNT/LMNT_yxv1gc.jpg")
logo = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1678704380/favolist/app%20assets/product%20images/tim%20ferris/%E2%80%8BLMNT/LMNT_-_logo_cxltri.png")
product.photos.attach(io: product_image, filename: "product_image.jpg", content_type: "image/jpg")
product.logo.attach(io: logo, filename: "logo.jpg", content_type: "image/jpg")
product.save!
puts "Adding referral to #{product.title}"
referral = Referral.new(
  code: "DrinkLMNT.com/Tim",
  details: "Find your favorite flavor with a free LMNT Sample Pack, included with any purchase for a limited time. And if you don’t love your purchase for any reason, my friends at LMNT offer a no-questions-asked refund policy. This special offer is available here: DrinkLMNT.com/Tim.*"
)
referral.product = product
referral.save!
#-------------Ascent Protein----------------------------------------------------
puts "Creating product for Vincent"
product = Product.create!(
  title: "Ascent Protein",
  price: 41.99,
  review: "Ever since I wrote The 4-Hour Body, starting my day with ~30 grams of protein has been an essential part of my routine. I’ve been using Ascent’s whey protein for the last several years, and I recently tried their new plant-based protein. I’ve experimented with many other plant-based proteins, and most compromise on taste or efficacy, but Ascent Plant Protein is delicious and provides 25 grams of protein with 4 grams of BCAAs to support muscle health. To ensure their product tastes great, Ascent verified it with third-party consumer research, and it won on taste and texture against the market leader. What’s more, it’s made from organic, real-food sources like organic pea, pumpkin, and sunflower and contains zero artificial ingredients, artificial sweeteners, or added sugars. ",
  description: "Ascent’s Vanilla Bean Plant Protein was created with two goals in mind: deliver a plant protein that tastes great and provides a complete amino acid profile to support your muscle health. A single scoop of Ascent plant protein delivers 25 grams of clean, certified organic, plant-based protein to help support muscle recovery.

  All athletes know that post-workout recovery requires more than protein. Our plant-based protein powders also included a complete amino acid profile including 4g of BCAAs.

  Unlike other plant protein options – which can be chalky and hard to drink – Ascent’s plant-based protein is the perfect blend that is delicious and smooth. Made from real food sources, our Vanilla Plant Based Protein mixes great with just water, almond milk, or in a smoothie. Our plant protein is slightly thicker than our whey protein, so we recommend mixing our Plant Protein with 12-14oz of liquid to get the perfect texture.

  Whether you’re mixing up a post-workout plant-based recovery drink, or adding some extra protein to your morning smoothie, our organic plant protein is something you’ll look forward to drinking.",
  list: health_hacks,
  url: "https://www.ascentprotein.com/"
)
product_image = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1685247479/Favolist%204.0/products/ascent_protein/ascent_protein_y3wiw6.webp")
logo = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1685246896/Favolist%204.0/products/ascent_protein/ascent_protein_logo_lufljg.jpg")
product.photos.attach(io: product_image, filename: "product_image.jpg", content_type: "image/jpg")
product.logo.attach(io: logo, filename: "logo.jpg", content_type: "image/jpg")
product.save!
puts "Adding referral to #{product.title}"
referral = Referral.new(
  code: "20TFASCENT",
  details: "Visit AscentProtein.com/Tim and use the code 20TFASCENT and you’ll receive 20% off of your entire purchase. This code is valid on their website and on Amazon.com. If you want a quick dose of protein to start your day or end a workout, this is a great option and my default. Enjoy!"
)
referral.product = product
referral.save!
#-----------UCAN Protein--------------------------------------------------------
puts "Creating product for Vincent"
product = Product.create!(
  title: "UCAN Energy Powder",
  price: 69.95,
  review: "I was introduced to UCAN and its unique carbohydrate SuperStarch by my good friend—and listener favorite—Dr. Peter Attia, who said there is no carb in the world like it. I have since included it in my routine, using UCAN’s powders to power my workouts, and the bars make great snacks. Extensive scientific research and clinical trials have shown that SuperStarch provides a sustained release of energy to the body without spiking blood sugar. UCAN is the ideal way to source energy from a carbohydrate without the negatives associated with fast carbs, especially sugar.

  You avoid fatigue, hunger cravings, and loss of focus. Whether you’re an athlete working on managing your fitness or you need healthy, efficient calories to get you through your day, UCAN is an elegant energy solution. ",
  description: "Designed to deliver a steady stream of energy to the mind and body, UCAN Energy Powders allow you to train longer at higher intensities with sustained energy. No sugar. No stimulants. Only clean, crash-free fuel to help you unlock next level performance.",
  list: health_hacks,
  url: "https://ucan.co/product-category/energy-powder/"
)
product_image = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1678942889/favolist/app%20assets/product%20images/tim%20ferris/UCAN/UCAN_v6ak4t.png")
logo = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1678942889/favolist/app%20assets/product%20images/tim%20ferris/UCAN/UCAN-logo_mc0uiy.png")
product.photos.attach(io: product_image, filename: "product_image.jpg", content_type: "image/jpg")
product.logo.attach(io: logo, filename: "logo.jpg", content_type: "image/jpg")
product.save!
puts "Adding referral to #{product.title}"
referral = Referral.new(
  code: "TIM",
  details: "My listeners can save 25% on their first UCAN order by going to ucan.co and using promo code TIM. US orders will also be shipped for free."
)
referral.product = product
referral.save!
#---------NOW Supplements-------------------------------------------------------
puts "Creating product for Vincent"
product = Product.create!(
  title: "NOW Supplements Alpha Lipoic Acid",
  price: 19.28,
  review: "I travel with insulin-mimetic compounds such as Alpha Lipoic Acid. These supplements allow you to minimize your own insulin response. Before I describe these, WARNING: I am not a doctor and don’t play one on the Internet. If you have any medical condition (especially Type I Diabetes), you need medical supervision to use such supplements.
  ",
  description: "Alpha lipoic acid (ALA) is naturally produced in the human body in very small amounts, but is also available through food sources. ALA is unique because it supports the body's free radical scavenging systems and can function in both water and fat environments.* ALA can also recycle the antioxidant vitamins C and E, thereby extending their activities.*",
  list: health_hacks,
  url: "https://www.amazon.com/dp/B0013OXBH6?tag=offsitoftimefe-20&geniuslink=true"
)
product_image = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1678923449/favolist/app%20assets/product%20images/tim%20ferris/Alpha%20Lipoic%20Acid/Alpha_Lipoic_Acid_unz945.jpg")
logo = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1678923448/favolist/app%20assets/product%20images/tim%20ferris/Alpha%20Lipoic%20Acid/Alpha_Lipoic_Acid-logo_kzukh5.jpg")
product.photos.attach(io: product_image, filename: "product_image.jpg", content_type: "image/jpg")
product.logo.attach(io: logo, filename: "logo.jpg", content_type: "image/jpg")
product.save!
#---------humann SuperBeets-----------------------------------------------------
puts "Creating product for Vincent"
product = Product.create!(
  title: "humann SuperBeets Sport",
  price: 35.95,
  review: "Add a tablespoon of this beet root powder to your Great Lakes Gelatin to stave off any cow-hoof flavor. Amelia Boone, mentioned above, uses this for pre-race and pre-training endurance benefits, but I'm much harder-core: I use it to make tart, low-carb gummy bears when fat Tim has carb cravings.Add a tablespoon of this beet root powder to your Great Lakes Gelatin to stave off any cow-hoof flavor. Amelia Boone, mentioned above, uses this for pre-race and pre-training endurance benefits, but I'm much harder-core: I use it to make tart, low-carb gummy bears when fat Tim has carb cravings.Add a tablespoon of this beet root powder to your Great Lakes Gelatin to stave off any cow-hoof flavor. Amelia Boone, mentioned above, uses this for pre-race and pre-training endurance benefits, but I'm much harder-core: I use it to make tart, low-carb gummy bears when fat Tim has carb cravings.",
  description: "You don’t have to be an elite athlete to train like one. Informed-Sport Certified and stimulant-free, BeetElite is a clean, plant-based pre-workout trusted by over 120 pro & college sports teams and clinically shown to increase stamina by 18%. Each scoop helps:
  Promote extended exercise endurance
  Promote improved energy & stamina
  Promote oxygen efficiency
  Promote Nitric Oxide production
  May help support respiratory health through Nitric Oxide production ",
  list: health_hacks,
  url: "https://humann.com/products/superbeets-superfood?variant=29389025935471"
)
product_image = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1678871315/favolist/app%20assets/product%20images/tim%20ferris/Beet%20Root%20Powder/Beet_Root_Powder-1_ves4cs.jpg")
logo = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1678871315/favolist/app%20assets/product%20images/tim%20ferris/Beet%20Root%20Powder/Beet_Root_Powder-logo_u8sgoi.png")
product.photos.attach(io: product_image, filename: "product_image.jpg", content_type: "image/jpg")
product.logo.attach(io: logo, filename: "logo.jpg", content_type: "image/jpg")
product.save!
#-------------Collagen Peptides-------------------------------------------------
puts "Creating product for Vincent"
product = Product.create!(
  title: "Collagen Peptides Powder Supplement",
  price: 25.19,
  review: "This product was recommended to me by Amelia Boone, known as the Michael Jordan of obstacle course racing.
  I've consumed gelatin for connective tissue repair in the past, but never stuck with it because of its texture. Amelia saved my palate and joints by recommending this type, which blends easily.",
  description: "Our collagen, made of ONE simple ingredient is a dietary supplement with a beneficial combination of amino acids. At Great Lakes Wellness, we believe that a healthy lifestyle and a balanced diet including collagen, is the cornerstone to a life well-lived. Collagen is nearly tasteless, colorless and odorless, and it is easily digested. It will not congeal in cold liquids making it a perfect addition to cold and hot beverages, smoothies or recipes. Just mix in and enjoy!",
  list: health_hacks,
  url: "https://www.amazon.com/dp/B005KG7EDU?tag=offsitoftimefe-20&geniuslink=true"
)
product_image = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1678871418/favolist/app%20assets/product%20images/tim%20ferris/Collagen%20Peptides%20Powder/Collagen_Peptides_Powder_zrdbad.jpg")
logo = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1678871417/favolist/app%20assets/product%20images/tim%20ferris/Collagen%20Peptides%20Powder/Great_Lakes_-_logo_i4itg4.jpg")
product.photos.attach(io: product_image, filename: "product_image.jpg", content_type: "image/jpg")
product.logo.attach(io: logo, filename: "logo.jpg", content_type: "image/jpg")
product.save!
#-------------Nordic Naturals --------------------------------------------------
puts "Creating product for Vincent"
product = Product.create!(
  title: "Nordict Naturals ProOmega®",
  price: 34,
  review: "Kevin Rose: Can I ask you what manufacturer of omega-3s do you take?

  Tim Ferriss: Yeah, I can tell you, let me grab it.

  Kevin Rose: All right. Tim has left the room. Let’s see if this makes the edit or not. I’m betting it’s Carlson Wild Caught Omega-3s.

  Tim Ferriss: Here we are.

  Kevin Rose: You have another one.

  Tim Ferriss: These are delicious. Don’t judge me, Kevin. This is not my usual, but in any case. All right. I’ve two here, this is a Nordic Naturals ProOmega 650 EPA/450 DHA. And that is right here, this guy, which I’ve been using. And then the second that I have is Thorne, that’s T-H-O-R-N-E Super EPA. And that’s this guy right here.

  Those are what I ended up choosing. And the effect is really remarkable and it’s difficult, I would say it’s impossible, let me be clear. It’s impossible for me to say that my sleep quality improvements are entirely caused by this. I’m also spending more time outside. I’m doing rucksacking. I’m getting more exercise. I’m getting a lot more sun exposure. I’m in nature. My body tends to just down-regulate, it’s not the right word, but my nervous system downshifts a lot when I’m surrounded by nature.

  Kevin Rose: It’s huge.

  Tim Ferriss: So there are many factors and there are many environmental changes in my life that have taken place in the last few weeks. But I have spent a lot of time in nature at many other points and my sleep has not had this dramatic change. So it leads me to think that there are other causal factors. And this is the most obvious. This is the most obvious thing.",
  description: "DAILY WELLNESS: For your daily routine, 12 grams of unflavored collagen hydrolysate per serving. Types I and III hydrolyzed collagen provide the amino acids necessary to support hair, skin, nail, and joint health.
  HYDROLYZED FORMULA: An easy way to supplement collagen into your diet. Great Lakes Wellness Collagen Peptides Powder provides support for collagen production as we age. Good for men and women.
  QUICK DISSOLVE: Collagen Peptides Powder is sourced from grass-fed bovine. Easily digested and absorbed by the body quickly for maximum benefits.
  EASY TO USE: Daily Wellness Quick Dissolve Collagen Peptides is easy to add to hot or cold liquids. Perfect for coffee, tea, smoothies, or recipes.
  MADE FOR YOU: iGen Non-GMO Tested, Paleo-Friendly, KETO-Certified, Gluten-Free, No Preservatives, Glyphosate Free, Kosher, and Halal. No added dairy, sugars, or sweeteners. Flavorless and odorless.",
  list: health_hacks,
  url: "https://www.amazon.com/Nordic-Naturals-ProOmega-High-Intensity-Cardiovascular/dp/B07CZSW26G/?tag=offsitoftimfe-20"
)
product_image = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1685247054/Favolist%204.0/products/nordic%20naturals/nordic_naturals_qsfbtz.jpg")
logo = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1685243216/Favolist%204.0/products/nordic%20naturals/nordic_naturals_zojce1.jpg")
product.photos.attach(io: product_image, filename: "product_image.jpg", content_type: "image/jpg")
product.logo.attach(io: logo, filename: "logo.jpg", content_type: "image/jpg")
product.save!
#-------------Baobest Baobab Fruit Powder --------------------------------------
puts "Creating product for Vincent"
product = Product.create!(
  title: "Baobest Baobab Fruit Powder",
  price: 14.99,
  review: "Baobest Baobab Fruit Powder, 16 Ounce, Organic Baobab Superfruit Powder , An Adaptogen With Electrolytes for Natural Energy, Baobab Super Fruit Contains Prebiotic Fiber, Antioxidants, Electrolytes,
  BAOBEST ORGANIC BAOBAB SUPERFRUIT POWDER : Baobab is a super fruit packed with prebiotic fiber, electrolytes and antioxidants which supports a healthy gut and immune system. Mix with water or juice or add to smoothies, yogurt, & oatmeal.
  ORGANIC BAOBAB POWDER: Baobest's Baobab powder is a great addition to fruity protein smoothies, water or juice. Nature's Sports Drink which delivers an electrolyte, fiber and antioxidant boost.
  COMMITTED TO QUALITY: With our own processing facility in South Africa, we are involved at every step of the supply chain, bringing you Babobest's highest quality certified USDA Organic & non-GMO Baobab super fruit powders, drinks mixes and fruit snacks.
  BAOBAB QUEEN OF SUPERFRUITS: Baobab powder comes from dried baobab fruit. Baobab is 50% dietary fiber, of which 75% is soluble prebiotic dietary fiber; supports healthy blood glucose levels, & contains adaptogens, which help the body respond to stressors.
  QUALITY AFRICAN BAOBAB FRUIT POWDER: At the heart of all our products is quality baobab powder. You'll love Baobest if you've enjoyed products from Trim Healthy Mama (THM), LivFIt, Better Body Foods, Aduna, Terrasoul Superfoods, Amina Baobab & Alaffia.
  ",
  description: "Baobab is a super fruit packed with prebiotic fiber, electrolytes and antioxidants which supports a healthy gut and immune system. Mix with water or juice or add to smoothies, yogurt, & oatmeal.",
  list: health_hacks,
  url: "https://www.amazon.com/gp/product/B00B93GV6Y/ref=as_li_ss_tl?ie=UTF8&th=1&linkCode=sl1&tag=offsitoftimfe-20&linkId=b1cb8e06d30a55b83476df2825390722"
)
product_image = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1685246541/Favolist%204.0/products/baobest%27/baobest_pgkbuy.jpg")
logo = URI.open("https://res.cloudinary.com/dncij7vr6/image/upload/v1685246575/Favolist%204.0/products/baobest%27/baobest_logo_h1cfgl.jpg")
product.photos.attach(io: product_image, filename: "product_image.jpg", content_type: "image/jpg")
product.logo.attach(io: logo, filename: "logo.jpg", content_type: "image/jpg")
product.save!
