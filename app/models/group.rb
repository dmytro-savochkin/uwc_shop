class Group < ActiveRecord::Base
  self.inheritance_column = :_type_disabled
  attr_accessible :link, :title, :type, :category_link
end
