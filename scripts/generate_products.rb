require 'cicero'
require 'rubystats'
require 'yaml'

# Set seed for randomness-based events
srand(1337)

SKUS_PER_PRODUCT_RATIO = [1, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 4, 4, 5]

PRODUCTS_WORDS = [
  'Electronic', 'Refrigerator', 'Fridge', 'Deep Freezer', 'Microwave Oven',
  'Washing Machine', 'Dryer', 'Stove', 'Oven', 'Vacuum Cleaner', 'Mixer',
  'Toaster', 'Food Processor', 'Iron', 'Fan', 'Air Conditioner', 'Heater',
  'Humidifier', 'Hair Dryer', 'Electric Razor', 'Television', 'Radio',
  'Telephone', 'Cell Phone', 'Smart Phone', 'Digital Camera', 'Video Camera',
  'Camcorder', 'Fax Machine', 'Calculator', 'Monitor', 'Keyboard', 'Printer',
  'Speaker', 'Laptop', 'Tablet', 'Coffee Maker', 'Iron', 'Lantern',
  'MP3 Player', 'Sewing Machine', 'Flash Drive', 'USB Drive', 'Webcam',
  'Remote Control', 'Memory Card', 'Scale', 'Dish Washer', 'Bathrobe', 'Belt',
  'Shirt', 'Shorts', 'Skirt', 'Suit', 'Suspenders', 'Sweater',
  'Swimming Shorts', 'T-Shirt', 'Thong', 'Tie', 'Top', 'Tracksuit', 'Trousers',
  'Turtleneck', 'Tuxedo', 'Underwear', 'Uniform', 'CD', 'Vinyl' ,'DVD',
  'Blu-ray', 'Game Console', 'Book'
].freeze

MEANINGLESS_WORDS = [
  'Foobar', 'Foo', 'Bar', 'Baz', 'Qux', 'Quux', 'Quuz', 'Corge', 'Grault',
  'Garply', 'Waldop', 'Dredz', 'Plugh', 'Plumbus', 'Thud', 'Ploo', 'Dinglebop',
  'Blurri', 'Iponno', 'Girzes', 'Platpor', 'Happor', 'Cruts', 'Murkmellow'
].freeze

ADJECTIVES = [
  'Premium', 'Deluxe', 'Basic', 'New', 'Super', 'Efficient', 'Clean', 'Gamer',
  'Special', 'Plain', 'Modern', 'XL'
].freeze

BRANDS = [
  'Angelwalk', 'Apachespace', 'Banshe Electronis', 'Beedlectrics',
  'Blossom Microsystems', 'Butterfly Media', 'Core Records', 'Dragonex',
  'Forestics', 'Fridge.ly', 'Goldworth', 'Greenbar', 'Griffin Motors',
  'Happindustries', 'High Tide', 'Ironforce', 'Karmarts', 'Lagoonscape',
  'Lionessolutions', 'Mermedia', 'Ogreprises', 'Omegascape', 'Pearlpaw',
  'Plextronics', 'Primespace', 'Proton Co.', 'Rabbit Lighting', 'Red Media',
  'Riddle Security', 'Ridgeco', 'Rivertime', 'Sharkfinetworks',
  'Soul Softwares', 'Squid Brews', 'SupplyChip', 'Tempest Technologies',
  'Thorecords', 'Thunderecords', 'Trekords', 'Twisterecords', 'Vertex Corp',
  'Wavestones', 'Whirlpoolutions'
].freeze

COLORS = [
  'White', 'Yellow', 'Blue', 'Red', 'Green', 'Black', 'Brown', 'Azure', 'Ivory',
  'Teal', 'Silver', 'Purple', 'Navy blue', 'Pea green', 'Gray', 'Orange',
  'Maroon', 'Charcoal', 'Aquamarine', 'Coral', 'Fuchsia', 'Wheat', 'Lime',
  'Crimson', 'Khaki', 'Hot pink', 'Magenta', 'Olden', 'Plum', 'Olive', 'Cyan'
].freeze

# Load categories
leaf_categories = File.readlines('categories.txt').map do |line|
  if line.strip.end_with?('END')
    line.split(' >> ')[0..-2]
  end
end.compact

# Generate 1000 products (more SKUs than this)
1000.times do |i|
  product = {
    'product_id'  => i.to_s.rjust(5, '0'),
    'brand'       => BRANDS.sample,
    'description' => Cicero.sentences(rand(0..10))
  }

  title = []
  title << ADJECTIVES.sample while rand(100) > 90
  title << product['brand'] if rand(100) > 95
  title << MEANINGLESS_WORDS.sample
  title << MEANINGLESS_WORDS.sample while rand(100) > 95
  title << PRODUCTS_WORDS.sample
  product['title'] = title.join(' ')

  product['skus'] = COLORS.sample(SKUS_PER_PRODUCT_RATIO.sample).map.with_index do |color, i|
    # 88% of chance of not being on a promotion
    promotion = rand(100) > 88
    # Price a mean of 50 and std of 10
    oldPrice = Rubystats::NormalDistribution.new(50, 10).rng
    if promotion
      # Discounts go from 5% to 45%
      discount = rand(0.05..0.45)
      currentPrice = (oldPrice*(1.0-discount))
    else
      discount = 0.0
      currentPrice = oldPrice
    end

    sku = "S#{product['product_id']}#{(i + 1).to_s.rjust(2, '0')}"

    {
      'available'    => rand(100) < 97,
      'condition'    => 'New',
      'currentPrice' => currentPrice.round(2).to_s,
      'discount'     => discount.round(2).to_s,
      'oldPrice'     => oldPrice.round(2).to_s,
      'promotion'    => promotion,
      'sku'          => sku,
      'skuName'      => "#{product['title']} - #{color}",
      'thumbnailURL' => "https://picsum.photos/seed/#{sku}/300/300",
      'imageURL'     => "https://picsum.photos/seed/#{sku}/600/600"
    }
  end

  # Jekyll elements
  product['layout'] = 'product'

  # Categories of the product
  product['categories'] = leaf_categories.sample([1, 1, 1, 1, 1, 1, 1, 2, 2, 3].sample)

  File.open("_products/#{product['product_id']}.md", 'w') { |file| file.write(product.to_yaml + "---\n") }
end
