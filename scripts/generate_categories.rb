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
    categories[l1][l2] = 'END'
  else
    categories[l1][l2] = {} if !categories[l1].key?(l2)
  end

  if l4.nil?
    categories[l1][l2][l3] = 'END' if !l3.nil?
  else
    categories[l1][l2][l3] = {} if !categories[l1][l2].key?(l3)
    categories[l1][l2][l3][l4] = 'END'
  end
end

def remove_bad_characterd(string)
  string.gsub(/[^a-zA-Z0-9\-]/,'_').gsub(/_+/,'_').downcase
end

categories.each do |k1, v1|
  # Level 1
  category = {
    'layout'                => 'category',
    'permalink'             => "/categories/#{remove_bad_characterd(k1)}",
    'leaf_category'         => false,
    'path_to_this_category' => [k1],
    'child_categories'      => v1.keys
  }

  filename = remove_bad_characterd(category['path_to_this_category'].join('_'))
  File.open("_categories/#{filename}.md", 'w') { |file| file.write(category.to_yaml + "---\n") }
end

