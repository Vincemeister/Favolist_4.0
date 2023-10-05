require 'uri'
require 'net/http'
require 'nokogiri'


class ScrapeAppsController < ApplicationController

    def fetch_app_id
      url = URI("https://api.apilayer.com/app_store/search/us?q=#{params[:app_name]}")
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

      https = Net::HTTP.new(url.host, url.port);
      https.use_ssl = true

      request = Net::HTTP::Get.new(url)
      request['apikey'] = "gBFhnFuUMbsnHi8tBpa6CYA2RV8xTlMv"

      response = https.request(request)
      puts response.read_body

      title = JSON.parse(response.read_body)["title"]
      puts "TITLE #{title}"

      price = JSON.parse(response.read_body)["price"]
      puts "PRICE #{price}"

      description = JSON.parse(response.read_body)["description"]
      puts "DESCRIPTION #{description}"

      logo = JSON.parse(response.read_body)["icon"]
      puts "LOGO #{logo}"

      link = JSON.parse(response.read_body)["developerWebsite"]
      puts "LINK #{link}"

      images = JSON.parse(response.read_body)["screenshots"]
      puts "IMAGES #{images}"


      product_data = { title: title, price: price, description: description, logo: logo, images: images, url: link }
      puts product_data

      product_data # return the product data
    end



end
