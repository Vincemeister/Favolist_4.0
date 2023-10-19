namespace :convert_prices do
  desc 'Convert existing float prices to integer cents'
  task to_money: :environment do
    Product.find_each do |product|
      puts "Processing Product ID #{product.id} with price #{product.price.inspect}"
      if product.price.present? && product.price.is_a?(Numeric)
        price_cents = (product.price * 100).to_i
        product.update_columns(price_cents: price_cents, price_currency: 'USD')
        puts "Updated Product ID #{product.id} to #{price_cents} cents"
      else
        puts "Skipped Product ID #{product.id} because the price is nil or invalid"
      end
    end
  end
end
