require 'uri'
require 'net/http'
require 'nokogiri'

class ScrapeProductsController < ApplicationController


  def fetch_product
  # to amazon
    if params[:link].include?("amazon")
      fetch_amazon_product
    elsif params[:link].include?("tokopedia")
      fetch_tokopedia_product
    elsif params[:link].include?("shopee")
      fetch_shopee_product
    else
      fetch_generic_product
    end
  end


  def fetch_amazon_product
    product_data = fetch_product_from_amazon(params[:link])
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

  def fetch_generic_product
    product_data = fetch_product_from_generic_store(params[:link])

    if product_data.present?
      session[:product_data] = product_data
      redirect_to new_product_path
    else
      flash[:error] = 'Failed to fetch product data from store.'
      redirect_to search_or_manual_product_upload_path
    end
  end

  def fetch_tokopedia_product
    product_data = fetch_product_from_tokopedia(params[:link])
    if product_data.present?
      session[:product_data] = product_data
      redirect_to new_product_path
    else
      flash[:error] = 'Failed to fetch product data from store.'
      redirect_to search_or_manual_product_upload_path
    end
  end

  def fetch_shopee_product
    product_data = fetch_product_from_shopee(params[:link])
    if product_data.present?
      session[:product_data] = product_data
      redirect_to new_product_path
    else
      flash[:error] = 'Failed to fetch product data from store.'
      redirect_to search_or_manual_product_upload_path
    end
  end



  private




  def fetch_product_from_amazon(url)
    require 'uri'
    require 'net/http'

    url_encoded = URI.encode_www_form_component(url)
    request_url = URI("https://axesso-axesso-amazon-data-service-v1.p.rapidapi.com/amz/amazon-lookup-product?url=#{url_encoded}")

    http = Net::HTTP.new(request_url.host, request_url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(request_url)
    request["X-RapidAPI-Key"] = '971b32dc4emshdc908738f2fb7c0p15bcc5jsn4f8c98db4f7d'
    request["X-RapidAPI-Host"] = 'axesso-axesso-amazon-data-service-v1.p.rapidapi.com'

    response = http.request(request)
    puts response.read_body
    response_body = JSON.parse(response.body) # convert the JSON response to a Ruby hash
    puts response_body

    # Extracting the title, price, and description
    title = response_body["productTitle"].split(/, |- |\| /)[0]
    price = response_body["price"]
    # currency = response_body["currencyAbbreviation"]
    currency = "USD"
    puts "CURRENCY: #{currency}"



    # Start with the product's description if it's a non-empty string.
    features = response_body["features"]
    description = if response_body["productDescription"].is_a?(String) && !response_body["productDescription"].strip.empty?
                    response_body["productDescription"].strip
                  else
                    ''
                  end

    # Append features if they exist.
    if features && features.any?
      description += "\n\n\u2022 " + features.join("\n\u2022 ")
    end

    # Set a default message if the description is still blank.
    description = "Description not found" if description.strip.empty?




    link = url
    # Extract all high resolution images
    images = response_body["imageUrlList"]


    puts "URL: #{link}"

    # Here, you can create a new instance of Product, or return these values as a hash
    product_data = { title: title, price: price, description: description, images: images, url: link, source: "amazon", currency: currency }
    puts product_data

    product_data # return the product data

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
  # if using cookie storage, need to limit to  images.first(4) otherwise cookie overflow over 4kb. However, using redis storage
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
    puts product_data
    product_data # return the product data
  end


  def fetch_product_from_generic_store(input_url)
    # Encode the URL first
    puts "RUNNING FETCH PRODUCT FROM GENERIC STORE"
    encoded_url = URI.encode_www_form_component(input_url)

    # Construct the OpenGraph API URL
    opengraph_url = URI("https://opengraph.io/api/1.1/site/#{encoded_url}?&cache_ok=false&full_render=true&app_id=44aa9636-f222-4b56-96c7-b14c3b8d7577")

    http = Net::HTTP.new(opengraph_url.host, opengraph_url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(opengraph_url)
    response = http.request(request)

    # Handle non-successful HTTP responses
    unless response.is_a?(Net::HTTPSuccess)
      puts "HTTP Error: #{response.message}"
      return nil
    end

    begin
      data = JSON.parse(response.body)

      # Validate and extract data
      title = data.dig("htmlInferred", "title") || "Unknown Title"
      price = data.dig("hybridGraph", "products", 0, "offers", 0, "price") || data.dig("hybridGraph", "price") || 0
      description = data.dig("htmlInferred", "description") || ""
      images = (data.dig("htmlInferred", "images") || []).reject do |img|
        img_downcased = img.downcase
        %w(.svg badge logo icon flag thumb).any? { |word| img_downcased.include?(word) }
      end
      images = images.first(15)

      # EXTRACT LOGO FROM BRANDR API - HOWEVER, IT SEEMS ITS MOSTLY THE SAME AS FAVICON SO TO SAFE SPEED I WILL OMMMIT EXTRA FETCH
      # logo_url = URI("https://brandr.p.rapidapi.com/extract")
      # logo_http = Net::HTTP.new(logo_url.host, logo_url.port)
      # logo_http.use_ssl = true

      # logo_request = Net::HTTP::Post.new(logo_url)
      # logo_request["content-type"] = 'application/x-www-form-urlencoded'
      # logo_request["X-RapidAPI-Key"] = 'your_api_key_here'
      # logo_request["X-RapidAPI-Host"] = 'brandr.p.rapidapi.com'
      # logo_request.body = "endpoint=#{input_url}"

      # logo_response = logo_http.request(logo_request)
      # logo_data = JSON.parse(logo_response.body)
      # logo = logo_data.dig("extractions", "dom-logo")

      # # ELSE JUST USE THE FAVICON if logo from brandr API is nil or empty
      # if logo.nil? || logo.empty?
      #   logo = data.dig("htmlInferred", "favicon")
      #   # If the logo URL is an SVG, set it to nil
      #   logo = nil if logo&.end_with?('.svg')
      # end

      logo = data.dig("htmlInferred", "favicon")
      # If the logo URL is an SVG, set it to nil
      logo = nil if logo&.end_with?('.svg')
      product_data = { title: title, price: price, description: description, url: input_url, images: images, logo: logo, currency: "USD", source: "generic" }
      puts "GENERIC STORE PRODUCT DATA: #{product_data}"
      product_data

    rescue JSON::ParserError => e
      puts "JSON Error: #{e.message}"
      nil
    rescue => e # General error handling
      puts "An error occurred: #{e.message}"
      nil
    end
  end

  def fetch_product_from_tokopedia(url)
    uri = URI.parse(url)
    slug = uri.path + (uri.query ? "?#{uri.query}" : "")
    encoded_slug = CGI.escape(slug)
    api_url = URI("https://tokopediaapi.p.rapidapi.com/?act=detail&slug=#{encoded_slug}&_pretty=true")

    http = Net::HTTP.new(api_url.host, api_url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(api_url)
    request["X-RapidAPI-Key"] = '971b32dc4emshdc908738f2fb7c0p15bcc5jsn4f8c98db4f7d'
    request["X-RapidAPI-Host"] = 'tokopediaapi.p.rapidapi.com'

    response = http.request(request)
    puts response.read_body

    if response.is_a?(Net::HTTPSuccess)
        response_body = JSON.parse(response.body) rescue {}

        title = response_body["title"]
        price = response_body["price"].gsub(/[^\d]/, '').to_i if response_body["price"]

        description = response_body["description"]
        images = response_body["images"]

        product_data = {
            title: title,
            price: price,
            description: description,
            url: url,
            images: images,
            source: "tokopedia",
            currency: "IDR"
        }

        puts product_data
    else
        puts "Failed to retrieve the product data"
    end

    product_data
  end



  
  def fetch_product_from_shopee(url)
    api_url = URI("https://shopee-e-commerce-data.p.rapidapi.com/shopee/item_detail_by_url/v2")

    http = Net::HTTP.new(api_url.host, api_url.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(api_url)
    request["content-type"] = 'application/json'
    request["X-RapidAPI-Key"] = '971b32dc4emshdc908738f2fb7c0p15bcc5jsn4f8c98db4f7d'
    request["X-RapidAPI-Host"] = 'shopee-e-commerce-data.p.rapidapi.com'
    request.body = {
        url: url
    }.to_json

    response = http.request(request)
    data = JSON.parse(response.body) rescue {}

    if response.is_a?(Net::HTTPSuccess) && data['code'] == 200
        item_data = data['data']

        title = item_data['title']
        price = item_data['price_info']['price'].to_f
        description = item_data['details']
        images = item_data['main_imgs']
        currency = item_data['currency']

        product_data = {
            title: title,
            price: price,
            description: description,
            url: url,
            images: images,
            source: "shopee",
            currency: currency
        }

        puts product_data  # For debugging; remove or replace with proper logging in production code
    else
        puts "Failed to retrieve the product data"
        return nil  # You might want to return a more informative error object here
    end

    product_data
end






end


  # OLD AMAZON FETCH REQUEST USING INFERIOR PARAZUN API

  # def fetch_amazon_product
  #   asin = extract_asin(params[:link])
  #   puts "Extracted ASIN: #{asin} from URL: #{params[:link]}"
  #   product_data = fetch_product_from_amazon(asin)

  #   if product_data.present?
  #     session[:product_data] = product_data
  #     redirect_to new_product_path
  #   else
  #     flash[:error] = 'Failed to fetch product data from Amazon.'
  #     redirect_to search_or_manual_product_upload_path
  #   end
  # end


  # def fetch_product_from_amazon(asin)
  #   url = URI("https://parazun-amazon-data.p.rapidapi.com/product/?asin=#{asin}&region=US")

  #   http = Net::HTTP.new(url.host, url.port)
  #   http.use_ssl = true

  #   request = Net::HTTP::Get.new(url)
  #   request["X-RapidAPI-Key"] = '971b32dc4emshdc908738f2fb7c0p15bcc5jsn4f8c98db4f7d'
  #   request["X-RapidAPI-Host"] = 'parazun-amazon-data.p.rapidapi.com'


  #   response = http.request(request)
  #   response_body = JSON.parse(response.body) # convert the JSON response to a Ruby hash

  #   # Print the ASIN and the response body
  #   puts "ASIN: #{asin}"
  #   puts "Response: #{response.body}"


  #   # Extracting the title, price, and description
  #   title = response_body["title"].split(/, |- |\| /)[0]
  #   price = response_body["price"]["amount"]



  #   # Start with the product's description if it's a non-empty string.
  #   features = response_body["features"]
  #   description = if response_body["description"].is_a?(String) && !response_body["description"].strip.empty?
  #                   response_body["description"].strip
  #                 else
  #                   ''
  #                 end

  #   # Append features if they exist.
  #   if features && features.any?
  #     description += "\n\u2022 " + features.join("\n\u2022 ")
  #   end

  #   # Set a default message if the description is still blank.
  #   description = "Description not found" if description.strip.empty?




  #   link = response_body["link"]
  #   # Extract all high resolution images
  #   images = response_body["images"].map do |image_hash|
  #     image_hash["hi_res"]
  #   end

  #   puts "URL: #{link}"

  #   # Here, you can create a new instance of Product, or return these values as a hash
  #   product_data = { title: title, price: price, description: description, images: images, url: link }
  #   puts product_data

  #   product_data # return the product data
  # end

  # def extract_asin(url)
  #   uri = URI(url)
  #   path_segments = uri.path.split('/')
  #   asin_index = path_segments.find_index('dp')
  #   asin_index ? path_segments[asin_index + 1] : nil
  # end
































# OLD CODE

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
