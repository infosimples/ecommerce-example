# Set seed for randomness-based events
srand(1337)

# List of meaningless words for the subcategories
MEANINGLESS_WORDS = [
  'Foobar', 'Foo', 'Bar', 'Baz', 'Qux', 'Quux', 'Quuz', 'Corge', 'Grault',
  'Garply', 'Waldop', 'Dredz', 'Plugh', 'Plumbus', 'Thud', 'Ploo', 'Dinglebop',
  'Blurri', 'Iponno', 'Girzes', 'Platpor', 'Happor', 'Cruts', 'Murkmellow'
].freeze

# Level 1 categories (must be meaningful)
LEVEL_1_CATEGORIES = [
  'Eletronics', 'Home', 'Health & Care', 'Pets', 'Fashion', 'Toys & Games',
  'Sports', 'Multimedia'
].freeze

# Ranges representing possible number of categories per level
N_LEVEL_2_CATEGORIES = 3..8
N_LEVEL_3_CATEGORIES = 0..6
N_LEVEL_4_CATEGORIES = 0..3

# Hash with our category hierarquies
categories = {}

# Open output file
f = File.open("categories.txt", 'w')

# Generate categories
LEVEL_1_CATEGORIES.each do |l1|
  # Generate level 1
  categories[l1] = {}
  f.puts(l1)

  # Generate level 2
  MEANINGLESS_WORDS.sample(rand(N_LEVEL_2_CATEGORIES)).each do |l2|
    categories[l1][l2] = {}
    l3_cats_num = rand(N_LEVEL_3_CATEGORIES)
    l3_cats_num == 0 ? cats = [l1, l2, 'END'] : cats = [l1, l2]
    f.puts(cats.join(' >> '))

    # Generate level 3
    MEANINGLESS_WORDS.sample(l3_cats_num).each do |l3|
      categories[l1][l2][l3] = {}
      l4_cats_num = rand(N_LEVEL_4_CATEGORIES)
      l4_cats_num == 0 ? cats = [l1, l2, l3, 'END'] : cats = [l1, l2, l3]
      f.puts(cats.join(' >> '))

      # Generate level 4
      MEANINGLESS_WORDS.sample(l4_cats_num).each do |l4|
        f.puts([l1, l2, l3, l4, 'END'].join(' >> '))
      end
    end
  end
end


