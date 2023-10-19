namespace :convert_prices do
  desc 'Convert existing float prices to money'
  task to_money: :environment do
    Product.find_each do |product|
      price_cents = (product.price * 100).to_i
      product.update_columns(price_cents: price_cents, price_currency: 'USD') # Set the appropriate currency code
    end
  end
end
