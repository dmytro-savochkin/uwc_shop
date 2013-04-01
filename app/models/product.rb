class Product < ActiveRecord::Base
  attr_accessible :availability, :category_id, :description, :link, :name, :photo, :photos, :price, :short_description
end
