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

def save_category(category)
  filename = remove_bad_characters(category['path_to_this_category'].map{|p| p['name']}.join('_'))
  File.open("_categories/#{filename}.md", 'w') { |file| file.write(category.to_yaml + "---\n") }
end

def generate_permalink(keys)
  "/categories/#{keys.map{|k| remove_bad_characters(k) }.join('/')}"
end

def generate_hash_with_name_and_category(names)
  names.each_with_index.map  do |v, i|
    {
      'name' => v,
      'url'  => generate_permalink(names.slice(0, i + 1))
    }
  end
end

categories.each do |k1, v1|
  # Level 1
  save_category({
    'layout'                => 'category',
    'permalink'             => generate_permalink([k1]),
    'leaf_category'         => false,
    'title'                 => "#{k1} - Commercia",
    'path_to_this_category' => generate_hash_with_name_and_category([k1]),
    'child_categories'      => v1.keys.map{|k| { 'name' => k, 'url' => generate_permalink([k1, k])}}
  })

  v1.each do |k2, v2|
    save_category({
      'layout'                => 'category',
      'permalink'             => generate_permalink([k1, k2]),
      'leaf_category'         => v2.empty?,
      'title'                 => "#{k2} - Commercia",
      'path_to_this_category' => generate_hash_with_name_and_category([k1, k2]),
      'child_categories'      => v2.keys.map{|k| { 'name' => k, 'url' => generate_permalink([k1, k2, k])}}
    })

    v2.each do |k3, v3|
      save_category({
        'layout'                => 'category',
        'permalink'             => generate_permalink([k1, k2, k3]),
        'leaf_category'         => v3.empty?,
        'title'                 => "#{k3} - Commercia",
        'path_to_this_category' => generate_hash_with_name_and_category([k1, k2, k3]),
        'child_categories'      => v3.keys.map{|k| { 'name' => k, 'url' => generate_permalink([k1, k2, k3, k])}}
      })

      v3.each do |k4, v4|
        save_category({
          'layout'                => 'category',
          'permalink'             => generate_permalink([k1, k2, k3, k4]),
          'leaf_category'         => v4.empty?,
          'title'                 => "#{k4} - Commercia",
          'path_to_this_category' => generate_hash_with_name_and_category([k1, k2, k3, k4]),
          'child_categories'      => []
        })
      end
    end
  end
end

