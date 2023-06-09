require 'uri'
require 'net/http'
require 'nokogiri'

class ScrapeProductsController < ApplicationController


  def fetch_product
  # to amazon
    if params[:link].include?("amazon")
      fetch_amazon_product
    else
      fetch_shopify_product
    end
  end



  def fetch_amazon_product
    asin = extract_asin(params[:link])
    puts "Extracted ASIN: #{asin} from URL: #{params[:link]}"
    product_data = fetch_product_from_amazon(asin)

    if product_data.present?
      session[:product_data] = product_data
      redirect_to new_product_path
    else
      flash[:error] = 'Failed to fetch product data from Amazon.'
      redirect_to search_or_manual_product_upload_path
    end
  end

  def fetch_shopify_product
    product_data = fetch_product_from_shopify(params[:link])

    if product_data.present?
      session[:product_data] = product_data
      redirect_to new_product_path
    else
      flash[:error] = 'Failed to fetch product data from Shopify.'
      redirect_to search_or_manual_product_upload_path
    end
  end

  private


  def fetch_product_from_amazon(asin)
    url = URI("https://parazun-amazon-data.p.rapidapi.com/product/?asin=#{asin}&region=US")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["X-RapidAPI-Key"] = '971b32dc4emshdc908738f2fb7c0p15bcc5jsn4f8c98db4f7d'
    request["X-RapidAPI-Host"] = 'parazun-amazon-data.p.rapidapi.com'


    response = http.request(request)
    response_body = JSON.parse(response.body) # convert the JSON response to a Ruby hash

    # Print the ASIN and the response body
    puts "ASIN: #{asin}"
    puts "Response: #{response.body}"


    # Extracting the title, price, and description
    title = response_body["title"].split(/, |- |\| /)[0]
    price = response_body["price"]["amount"]
    description = response_body["description"]&.join(' ') # join array elements into a single string
    link = response_body["link"]
    # Extract all high resolution images
    images = response_body["images"].map do |image_hash|
      image_hash["hi_res"]
    end

    puts "URL: #{link}"

    # Here, you can create a new instance of Product, or return these values as a hash
    product_data = { title: title, price: price, description: description, images: images, url: link }

    product_data # return the product data
  end

  def extract_asin(url)
    uri = URI(url)
    path_segments = uri.path.split('/')
    asin_index = path_segments.find_index('dp')
    asin_index ? path_segments[asin_index + 1] : nil
  end



  def fetch_product_from_shopify(url)
    product_url = URI("https://shopify-fast-scraper.p.rapidapi.com/product?url=#{url}")

    http = Net::HTTP.new(product_url.host, product_url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(product_url)
    request["X-RapidAPI-Key"] = '971b32dc4emshdc908738f2fb7c0p15bcc5jsn4f8c98db4f7d'
    request["X-RapidAPI-Host"] = 'shopify-fast-scraper.p.rapidapi.com'

    response = http.request(request)
    response_body = JSON.parse(response.body) # convert the JSON response to a Ruby hash
    title = response_body["product"]["vendor"] + " - " + response_body["product"]["title"]
    price = response_body["product"]["variants"][0]["price"]
    description = Nokogiri::HTML(response_body["product"]["body_html"]).text
    link = url

    images = response_body["product"]["images"].map do |image_hash|
      image_hash["src"]
    end

  images = images.first(4)

    # ----------------------------------------------------------------------------
    logo_url = URI("https://brandr.p.rapidapi.com/extract")

    http = Net::HTTP.new(logo_url.host, logo_url.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(logo_url)
    request["content-type"] = 'application/x-www-form-urlencoded'
    request["Content-Type"] = 'application/x-www-form-urlencoded'
    request["X-RapidAPI-Key"] = '971b32dc4emshdc908738f2fb7c0p15bcc5jsn4f8c98db4f7d'
    request["X-RapidAPI-Host"] = 'brandr.p.rapidapi.com'

    request.body = "endpoint=#{url}"
    response = http.request(request)
    # Convert the response body to a Ruby Hash
    response_hash = JSON.parse(response.body)
    # Extract the dom-logo
    logo = response_hash["extractions"]["dom-logo"]

    puts "LOGO RESPONSE: #{logo}"

    product_data = { title: title, price: price, description: description, url: link, images: images, logo: logo }

    product_data # return the product data
  end
end
# CREATE PRODUCT INSTEAD OF PASSING IT THROUGH THE SESSION TBD

# require 'uri'
# require 'net/http'
# require 'nokogiri'

# class ScrapeProductsController < ApplicationController


#   def fetch_product
#   # to amazon
#     if params[:link].include?("amazon")
#       fetch_amazon_product
#     else
#       fetch_shopify_product
#     end
#   end



#   def fetch_amazon_product
#     asin = extract_asin(params[:link])
#     puts "Extracted ASIN: #{asin} from URL: #{params[:link]}"
#     @product = fetch_product_from_amazon(asin)
#     redirect_to new_product_path(@product)
#   end




#   def fetch_shopify_product
#     product_data = fetch_product_from_shopify(params[:link])

#     if product_data.present?
#       session[:product_data] = product_data
#       redirect_to new_product_path
#     else
#       flash[:error] = 'Failed to fetch product data from Shopify.'
#       redirect_to search_or_manual_product_upload_path
#     end
#   end

#   private


#   def fetch_product_from_amazon(asin)
#     url = URI("https://parazun-amazon-data.p.rapidapi.com/product/?asin=#{asin}&region=US")

#     http = Net::HTTP.new(url.host, url.port)
#     http.use_ssl = true

#     request = Net::HTTP::Get.new(url)
#     request["X-RapidAPI-Key"] = '971b32dc4emshdc908738f2fb7c0p15bcc5jsn4f8c98db4f7d'
#     request["X-RapidAPI-Host"] = 'parazun-amazon-data.p.rapidapi.com'


#     response = http.request(request)
#     response_body = JSON.parse(response.body) # convert the JSON response to a Ruby hash

#     @product = Product.new(
#       title = response_body["title"].split(/, |- |\| /)[0],
#       price: response_body["price"]["amount"],
#       description: response_body["description"].join(' '),
#       url: response_body["link"]
#     )
#     session[:product_photos] = response_body["images"].map do |image_hash|
#       image_hash["hi_res"]
#     end
#     puts "SESSION PRODUCT PHOTOS: #{session[:product_photos]}"
#     @product
#   end

#   def extract_asin(url)
#     uri = URI(url)
#     path_segments = uri.path.split('/')
#     asin_index = path_segments.find_index('dp')
#     asin_index ? path_segments[asin_index + 1] : nil
#   end



#   def fetch_product_from_shopify(url)


#     product_url = URI("https://shopify-fast-scraper.p.rapidapi.com/product?url=#{url}")

#     http = Net::HTTP.new(product_url.host, product_url.port)
#     http.use_ssl = true

#     request = Net::HTTP::Get.new(product_url)
#     request["X-RapidAPI-Key"] = '971b32dc4emshdc908738f2fb7c0p15bcc5jsn4f8c98db4f7d'
#     request["X-RapidAPI-Host"] = 'shopify-fast-scraper.p.rapidapi.com'

#     response = http.request(request)
#     response_body = JSON.parse(response.body) # convert the JSON response to a Ruby hash
#     title = response_body["product"]["vendor"] + " - " + response_body["product"]["title"]
#     price = response_body["product"]["variants"][0]["price"]
#     description = Nokogiri::HTML(response_body["product"]["body_html"]).text
#     link = url

#     images = response_body["product"]["images"].map do |image_hash|
#       image_hash["src"]
#     end

#     # ----------------------------------------------------------------------------
#     logo_url = URI("https://brandr.p.rapidapi.com/extract")

#     http = Net::HTTP.new(logo_url.host, logo_url.port)
#     http.use_ssl = true

#     request = Net::HTTP::Post.new(logo_url)
#     request["content-type"] = 'application/x-www-form-urlencoded'
#     request["Content-Type"] = 'application/x-www-form-urlencoded'
#     request["X-RapidAPI-Key"] = '971b32dc4emshdc908738f2fb7c0p15bcc5jsn4f8c98db4f7d'
#     request["X-RapidAPI-Host"] = 'brandr.p.rapidapi.com'

#     request.body = "endpoint=#{url}"
#     response = http.request(request)
#     # Convert the response body to a Ruby Hash
#     response_hash = JSON.parse(response.body)
#     # Extract the dom-logo
#     logo = response_hash["extractions"]["dom-logo"]

#     puts "LOGO RESPONSE: #{logo}"

#     product_data = { title: title, price: price, description: description, url: link, images: images, logo: logo }

#     product_data # return the product data
#   end

# end
