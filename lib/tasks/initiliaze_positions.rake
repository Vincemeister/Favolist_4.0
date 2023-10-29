namespace :products do
  desc "Initialize positions for existing products"
  task initialize_positions: :environment do
    List.find_each do |list|
      list.products.order(created_at: :desc).each_with_index do |product, index|
        product.update_column(:position, index + 1)
      end
    end
  end
end


namespace :lists do
  desc "Initialize positions for existing lists per user"
  task initialize_positions: :environment do
    User.find_each do |user|
      user.lists.order(created_at: :desc).each_with_index do |list, index|
        list.update_column(:position, index + 1)
      end
    end
  end
end



namespace :referrals do
  desc "Initialize positions for existing referrals for each list"
  task initialize_positions: :environment do
    List.find_each do |list|
      list.referrals.order(created_at: :desc).each_with_index do |referral, index|
        referral.update_column(:position, index + 1)
        puts "Referral ID: #{referral.id} - Position: #{referral.position}"
      end
    end
  end
end
