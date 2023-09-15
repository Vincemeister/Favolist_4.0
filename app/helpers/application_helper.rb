module ApplicationHelper
  include CloudinaryHelper

  def generate_tiled_background(list, default_color = "$neutral-300")
    tiles = []
    products_with_photos = list.products.select { |p| p.photos.attached? }

    # Get the required number of products based on the count
    required_products = case products_with_photos.count
                        when 1..3 then products_with_photos.first(1)
                        when 4..8 then products_with_photos.first(4)
                        when 9..15 then products_with_photos.first(9)
                        else products_with_photos.first(16)
                        end

    # Generate the tiles for the required products
    required_products.each do |product|
      tiles << "<div class='tile' style='background-image: url(#{cl_image_path(product.photos.first.key)})'></div>"
    end

    # Fill in any missing tiles
    fill_tiles(tiles, required_products.length, default_color)

    grid_class = case required_products.length
                 when 1 then "list-card-background-grid-1"
                 when 2..4 then "list-card-background-grid-4"
                 when 5..9 then "list-card-background-grid-9"
                 else "list-card-background-grid-16"
                 end

    [tiles.join.html_safe, grid_class]
  end

  private

  def fill_tiles(tiles, current_count, color)
    target_count = case current_count
                   when 1 then 1
                   when 2..4 then 4
                   when 5..9 then 9
                   else 16
                   end

    while tiles.count < target_count
      tiles << "<div class='tile' style='background-image: linear-gradient(#{color}, #{color})'></div>"
    end
  end
end
