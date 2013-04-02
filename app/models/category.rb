class Category < ActiveRecord::Base
  attr_accessible :code, :name



  # build the classifiers (groups) tree for left panel in category page
  def build_groups_data(criteria)
    @category_link = self[:link]
    criteria, price_availability_criteria = parse_criteria(criteria)

    initialize_codes_and_values_translating_table

    products_map = build_products_map

    union_map = build_union_map(criteria, products_map)

    logger.info union_map

    products_ids_by_price_and_availability = product_ids_for_price_availability price_availability_criteria
    products_ids_by_all_criteria = products_ids_by_price_and_availability & union_map.values.inject(:&)


    output_tree = build_output_tree(
        products_map, union_map, products_ids_by_all_criteria,
        products_ids_by_price_and_availability, criteria, price_availability_criteria
    )




    [output_tree, products_ids_by_all_criteria]
  end












  private








  class << self
    # prefixes to types of groups
    def correct_prefixes
      {'u' => 'unique', 'nu' => 'non-unique', 's' => 'specific'}
    end
    # prefixes inverted
    def correct_prefixes_reverse
      self.correct_prefixes.invert
    end
    # prefix for price and availability classifiers
    def price_availability_prefix
      'ap'
    end
  end










  # Initialize the table of translating group codes and group values to corresponding
  # types and titles.
  def initialize_codes_and_values_translating_table
    @code_to = {:type => {}, :title => {}}
    @value_to = {}
  end
  # Fill the table of translating group codes and group values.
  def fill_codes_and_values_translating_table(group_value, code, index)
    @code_to[:type][code] = group_value['type']
    @code_to[:title][code] = group_value['group_title']
    @value_to[code] ||= {}
    @value_to[code][index] = group_value['group_value_title']
  end



  # Create map of products as an array of group values data and product ids for
  # these group values.
  def build_products_map()
    groups_values = groups_structure_by_join

    products_map = {}
    groups_values.each do |group_value|
      code = group_value['link']
      index = group_value['id'].to_i
      products_for_group_value = group_value['products']

      fill_codes_and_values_translating_table(group_value, code, index)

      products_map[code] ||= {}
      products_map[code][index] = products_for_group_value.split(',').map(&:strip).map(&:to_i)
    end
    products_map
  end



  # Build union map which is the simplification of products map
  # by using intersections and unions.
  # Example:
  # Product map [A1,A2,A3 x B1,B2 x C1]
  # Union map [A x B x C]
  def build_union_map(criteria, products_map)
    union_map = {}
    if criteria.empty?
      union_map['all'] = product_ids_for_category.map{|e|e[:id]}
    else
      criteria.each do |code, values|
        if values.length == 1
          union_map[code] = products_map[code].clone[values.first]
        elsif values.length > 1
          products_with_values_in_criterion = products_map[code].clone.keep_if{|k,v|values.include? k}.values
          case @code_to[:type][code]
            when "unique"
              union_map[code] = products_with_values_in_criterion.inject(:|)
            when "non-unique"
              union_map[code] = products_with_values_in_criterion.inject(:&)
            when "specific"
              union_map[code] = product_ids_for_specific_type_group(code, values).to_a.map(&:to_i)
            else
              raise "Wrong group type (link). How is it possible?"
          end
        end
      end
    end
    union_map
  end


















  # Parsing raw criteria string to criteria arrays
  # (one for price_availability data and one for other dynamic classifiers)
  def parse_criteria(criteria)
    price_availability_criteria = {}
    price_availability_criteria['price'] = (criteria['ap:price'].split(',')[0..1].map(&:to_i)) rescue nil
    price_availability_criteria['availability'] = (criteria['ap:availability'] || nil)

    criteria = criteria.clone.keep_if do |e|
      Category.correct_prefixes.keys.include? (e.split(':').first)
    end
    filtered_criteria = {}
    criteria.each do |e|
      prefix, class_link = e.first.split(':')
      splitted_value = e[1].split(',')
      splitted_value = splitted_value.map(&:to_i) if prefix == 'u' or prefix == 'nu'
      splitted_value = splitted_value.map(&:to_f) if prefix == 's'
      filtered_criteria[class_link] = splitted_value unless splitted_value.first.nil?
    end

    [filtered_criteria, price_availability_criteria]
  end



  # Is value selected? (exists in input criteria)
  def value_selected?(criteria, code, value)
    (criteria.keys.include? code) and (criteria[code].include? value)
  end







  # Build output tree which is used for building the left classifier
  # (group) menu.
  def build_output_tree(
      products_map, union_map, products_ids_by_all_criteria,
          products_ids_by_p_a, criteria, p_a_criteria
  )
    output_tree = {}
    products_map.each do |products_map_code, values|
      values.each do |value, product_ids_for_value|
        full_intersection = full_intersection(union_map, products_map_code, product_ids_for_value)
        group_in_criteria = union_map.keys.include? products_map_code
        full_intersection &= product_ids_for_value unless group_in_criteria
        full_intersection &= products_ids_by_p_a


        output_tree[products_map_code] ||= []


        

        output_tree[products_map_code].push output_hash(
             criteria, p_a_criteria,
             products_map_code, value,
             group_in_criteria,
             full_intersection, products_ids_by_all_criteria
        )
        
        
      end
    end

    output_tree
  end



  # Making output hashes which are used in building the left classifier
  # (group) menu.
  # Output for each classifier (group) value is a hash with parameters which include:
  # - corresponding codes with titles and values with titles;
  # - numerical difference between product_ids length in current criteria and
  # other (for particular iteration of group values cycle) criteria;
  # - new criteria string (for using as a link);
  # - also type and availability to click.
  def output_hash(
      criteria, p_a_criteria,
      code, value,
      group_in_criteria, intersection_ids, current_ids
    )

    criteria_clone = Marshal.load(Marshal.dump(criteria))

    group_type = @code_to[:type][code]
    value_selected = value_selected?(criteria_clone, code, value)

    if value_selected
      difference_for_group = 0
      criteria_string = criteria_clone.each do |code_in, values|
        if code_in == code and values.include? value
          values.delete_at(values.index(value))
        end
      end
    else
      if group_in_criteria
        criteria_clone[code].push value
      else
        criteria_clone[code] = [value]
      end
      criteria_string = criteria_clone
      case group_type
        when "unique"
          if group_in_criteria
            count = intersection_ids.length - current_ids.length
            difference_for_group = 0 if count <= 0
            difference_for_group = '+' + count.to_s if count > 0
          else
            difference_for_group = intersection_ids.length
          end
        when "non-unique"
          difference_for_group = intersection_ids.length
        when "specific"
          difference_for_group = 0
        else
          raise "Wrong group type (link). How is it possible?!"
      end
    end


    {
      :code => code,
      :code_title => @code_to[:title][code],
      :value => value,
      :value_title => @value_to[code][value],
      :criteria_link => criteria_hash_to_string(criteria_string.merge(p_a_criteria)),
      :type => group_type,
      :selected => value_selected,
      :available_to_click => (difference_for_group.to_i > 0 or value_selected),
      :value_in_brackets => difference_for_group
    }
  end




  # Convert criteria from hash to string.
  # Example:
  # {'memory' => [1,3,2,4], 'cpu' => [1,2]}
  # =>
  # 'type:memory=1,3,2,4&type:cpu=1,2'
  def criteria_hash_to_string(criteria)
    return '' unless criteria.is_a?(Hash)
    result_as_array = []
    criteria.each do |code, values|
      values = values.join(',') if values.is_a?(Array)
      if code == 'price' or code == 'availability'
        type = self.class.price_availability_prefix
      else
        type = Category.correct_prefixes_reverse[@code_to[:type][code]].to_s
      end
      result_as_array.push(type.to_s + ':' + code.to_s + '=' + values.to_s)
    end
    result_as_array.join('&')
  end



  # Find full intersection of product_ids for particular group_value
  def full_intersection(union_map, code, product_ids)
    group_type = @code_to[:type][code]
    full_intersection = nil
    union_map.each do |union_code, union_element|
      if union_code == code
        combination = union_element | product_ids if group_type == 'unique' or group_type == 'specific'
        combination = union_element & product_ids if group_type == 'non-unique'
      else
        combination = union_element
      end

      if full_intersection.nil?
        full_intersection = combination
      else
        full_intersection &= combination
      end
    end
    full_intersection
  end














  # IDs of products which are in some category AND meet price_availability criteria
  def product_ids_for_price_availability(criteria)
    products = Product.where('category_link = ?', @category_link)
    if criteria['price'] and criteria['price'].length == 2
      products = products.
          where('price > ?', criteria['price'].min).
          where('price < ?', criteria['price'].max)
    end
    unless criteria['availability'].nil? or criteria['availability'].empty?
      products = products.where('availability = ?', criteria['availability'].to_i)
    end
    products.select('id').map(&:id)
  end



  # IDs of products which are in some category
  def product_ids_for_category()
    Product.where('category_link = ?', @category_link).select('id')
  end



  def product_ids_for_specific_type_group(code, values)
    #TODO : to think how to get rid of that query

    table = 'groups_' + @category_link
    ActiveRecord::Base.connection.select_all("
      SELECT product_id FROM #{table} WHERE
      #{code} > #{values.min} AND #{code} < #{values.max}
    ")
  end



  # Make JOIN query to groups and their values structure for some category
  def groups_structure_by_join()
    groups_select = Group.where(:category_link => @category_link).to_sql
    group_values_select = GroupValues.where(:category_link => @category_link).to_sql

    ActiveRecord::Base.connection.select_all("
      SELECT
        A.category_link AS category_link,
        A.link AS link,
        A.title AS group_title,
        A.type AS type,
        B.id AS id,
        B.products AS products,
        B.title AS group_value_title
      FROM (#{groups_select}) AS A LEFT OUTER JOIN (#{group_values_select}) AS B
        ON A.link = B.group_link
    ")
  end
end
