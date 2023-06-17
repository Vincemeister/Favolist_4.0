require 'uri'
require 'net/http'
require 'nokogiri'

class ScrapeProductsController < ApplicationController

  def fetch_shopify_product
    product_data = fetch_product_from_shopify(params[:asin])

    if product_data.present?
      session[:product_data] = product_data
      redirect_to new_product_path
    else
      flash[:error] = 'Failed to fetch product data from Amazon.'
      redirect_to search_or_manual_product_upload_path
    end
  end

  private


  def fetch_product_from_shopify(url)


    product_url = URI("https://shopify-fast-scraper.p.rapidapi.com/product?url=#{url}")

    http = Net::HTTP.new(product_url.host, product_url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(product_url)
    request["X-RapidAPI-Key"] = '971b32dc4emshdc908738f2fb7c0p15bcc5jsn4f8c98db4f7d'
    request["X-RapidAPI-Host"] = 'shopify-fast-scraper.p.rapidapi.com'

    response = http.request(request)
    response_body = JSON.parse(response.body) # convert the JSON response to a Ruby hash
    title = response_body["product"]["title"]
    price = response_body["product"]["variants"][0]["price"]
    description = Nokogiri::HTML(response_body["product"]["body_html"]).text
    link = url

    images = response_body["product"]["images"].map do |image_hash|
      image_hash["src"]
    end

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
