class Faction < ActiveRecord::Base
  attr_accessible :link, :name
  has_many :categories, :foreign_key => 'faction_id'
end
