namespace :products do
  desc "Initialize positions for existing products"
  task initialize_positions: :environment do
    List.find_each do |list|
      list.products.order(:created_at).each_with_index do |product, index|
        product.update_column(:position, index + 1)
      end
    end
  end
end
