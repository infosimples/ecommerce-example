require 'yaml'

# Set seed for randomness-based events
srand(1337)

# Transform the categories in nested hash structure (like a tree)
leaves = File.readlines('categories.txt').map do |line|
  line.split(' >> ')[0..-2] if line.strip.end_with?('END')
end.compact

categories = {}
leaves.each do |leaf|
  l1, l2, l3, l4 = leaf

  categories[l1] = {} if !categories.key?(l1)

  if l3.nil?
    categories[l1][l2] = {}
  else
    categories[l1][l2] = {} if !categories[l1].key?(l2)
  end

  if l4.nil?
    categories[l1][l2][l3] = {} if !l3.nil?
  else
    categories[l1][l2][l3] = {} if !categories[l1][l2].key?(l3)
    categories[l1][l2][l3][l4] = {}
  end
end

def remove_bad_characters(string)
  string.gsub(/[^a-zA-Z0-9\-]/,'_').gsub(/_+/,'_').downcase
end

def save_category(category, i = 1)
  filename = remove_bad_characters(category['path_to_this_category'].map{|p| p['name']}.join('_'))
  File.open("_categories/#{filename}_#{i}.md", 'w') { |file| file.write(category.to_yaml + "---\n") }
end

def create_category(keys, current_value)
  i = 1
  url_base = generate_permalink(keys)
  path_to_this_category = keys.each_with_index.map{ |v, i|
    {
      'name' => v,
      'url'  => generate_permalink(keys.slice(0, i + 1))
    }
  }

  while(!@category_products[url_base].empty?)
    products = @category_products[url_base].shift(20)
    save_category({
      'layout'                => 'category',
      'permalink'             => "#{url_base}/#{i}",
      'leaf_category'         => current_value.empty?,
      'title'                 => "#{keys.last} - Commercia",
      'path_to_this_category' => path_to_this_category,
      'child_categories'      => current_value.keys.map{|k| { 'name' => k, 'url' => generate_permalink([*keys, k])}},
      'products'              => products,
      'first_page'            => i == 1,
      'last_page'             => @category_products[url_base].empty?
    }, i)
    i += 1
  end
end

def generate_permalink(keys)
  "/categories/#{keys.map{|k| remove_bad_characters(k) }.join('/')}"
end

# Get products for each category
@category_products = {}
Dir['_products/*'].each do |filename|
  product = YAML.load(File.read(filename))
  lowest_price_sku = product['skus'].min { |a,b| a['currentPrice'].to_f <=> b['currentPrice'].to_f }
  product_info = {
    'id'        => product['product_id'],
    'title'     => product['title'],
    'thumbnail' => lowest_price_sku['thumbnailURL'],
    'price'     => lowest_price_sku['currentPrice']
  }

  product['categories'].each do |category|
    (1..category.size).map{|a| category[0,a] }.each do |subcategory|
      url = generate_permalink(subcategory)
      if(@category_products.has_key?(url))
        @category_products[url] << product_info
      else
        @category_products[url] = [product_info]
      end
    end
  end
end

# Now, save the categories info to file
categories.each do |k1, v1|
  # Level 1
  create_category([k1], v1)

  v1.each do |k2, v2|
    # Level 2
    create_category([k1, k2], v2)

    v2.each do |k3, v3|
      # Level 3
      create_category([k1, k2, k3], v3)

      v3.each do |k4, v4|
        # Level 4
        create_category([k1, k2, k3, k4], v4)
      end
    end
  end
end

