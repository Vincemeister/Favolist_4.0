module ApplicationHelper
  include CloudinaryHelper

  def generate_tiled_background(list, default_color = "gray")
    products = list.products
    tiles = []
    number_of_tiles = if products.count.between?(1, 3)
                        1
                      elsif products.count.between?(4, 8)
                        4
                      elsif products.count.between?(9, 15)
                        9
                      else
                        16
                      end

    number_of_tiles.times do |i|
      if products[i] && products[i].photos.attached?
        tiles << "<div class='tile' style='background-image: url(#{cl_image_path(products[i].photos.first.key)})'></div>"
      else
        tiles << "<div class='tile' style='background-image: linear-gradient(#{default_color}, #{default_color})'></div>"
      end

    end

    grid_class = case number_of_tiles
                 when 1 then "list-grid-1"
                 when 4 then "list-grid-4"
                 when 9 then "list-grid-9"
                 else "list-grid-16"
                 end

    [tiles.join.html_safe, grid_class]
  end

  private

  def fill_tiles(tiles, desired_count, color)
    while tiles.count < desired_count
      tiles << "<div class='tile' style='background-image: linear-gradient(#{color}, #{color})'></div>"
    end
  end


  
end
