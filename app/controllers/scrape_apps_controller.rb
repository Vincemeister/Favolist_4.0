require 'uri'
require 'net/http'
require 'nokogiri'


class ScrapeAppsController < ApplicationController


  def fetch_app_or_website
    if params[:query].include?('www.') || params[:query].include?('http://') || params[:query].include?('https://')
      fetch_website(params[:query])
    else
      fetch_app_id(params[:query])
    end
  end

  def fetch_app_id(query)
    url = URI("https://api.apilayer.com/app_store/search/us?q=#{query}")
    https = Net::HTTP.new(url.host, url.port);
    https.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request['apikey'] = "gBFhnFuUMbsnHi8tBpa6CYA2RV8xTlMv"

    response = https.request(request)
    puts response.read_body

    app_id = JSON.parse(response.read_body)[0]
    puts "APP ID #{app_id}"

    product_data = fetch_app(app_id)

    if product_data.present?
      session[:product_data] = product_data
      redirect_to new_product_path
    else
      flash[:error] = 'Failed to fetch product data from Shopify.'
      redirect_to search_or_manual_app_upload_path
    end
  end

  def fetch_app(app_id)
    url = URI("https://api.apilayer.com/app_store/app/us/#{app_id}")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request['apikey'] = "gBFhnFuUMbsnHi8tBpa6CYA2RV8xTlMv"

    response = https.request(request)
    data = JSON.parse(response.read_body)

    title = data["title"]
    price = data["price"]
    description = data["description"]
    logo = data["icon"]
    link = data["developerWebsite"]
    images = data["screenshots"]
    currency = data["currency"] || "USD"

    product_data = { title: title, price: price, currency: currency, description: description, logo: logo, images: images, url: link }

    # Print all at once, you can comment this out in production
    puts "TITLE: #{title}\nPRICE: #{price}\nDESCRIPTION: #{description}\nLOGO: #{logo}\nLINK: #{link}\nIMAGES: #{images}\nPRODUCT DATA: #{product_data}"

    product_data # return the product data
  end

  def fetch_website(query)
    query = "https://#{query}" unless query.start_with?('http://', 'https://')
    puts "QUERY: #{query}"

    encoded_url = URI.encode_www_form_component(query)
    puts "ENCODED URL: #{encoded_url}"
    opengraph_url = URI("https://opengraph.io/api/1.1/site/#{encoded_url}?accept_lang=auto&cache_ok=false&use_proxy=true&use_superior=true&app_id=44aa9636-f222-4b56-96c7-b14c3b8d7577")
    puts "OPENGRAPH URL: #{opengraph_url}"
    http = Net::HTTP.new(opengraph_url.host, opengraph_url.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(opengraph_url)
    response = http.request(request)
    puts "RESPONSE: #{response}"
    data = JSON.parse(response.body)
    puts "DATA: #{data}"
    begin
      data = JSON.parse(response.body)

      # Validate and extract data
      title = data.dig("htmlInferred", "title") || "Unknown Title"
      price = 0
      currency = data.dig("htmlInferred", "price")? data.dig("htmlInferred", "price") : "USD"
      description = data.dig("htmlInferred", "description") || ""
      images = [data.dig("openGraph", "image", "url")].compact


      logo = data.dig("htmlInferred", "favicon")
      # If the logo URL is an SVG, set it to nil
      logo = nil if logo&.end_with?('.svg')
      product_data = { title: title, price: price, currency: currency, description: description, url: query, images: images, logo: logo }
      puts "GENERIC STORE PRODUCT DATA: #{product_data}"
      product_data

      if product_data.present?
        session[:product_data] = product_data
        redirect_to new_product_path
      else
        flash[:error] = 'Failed to fetch product data from Shopify.'
        redirect_to search_or_manual_app_upload_path
      end
    end
  end
end
