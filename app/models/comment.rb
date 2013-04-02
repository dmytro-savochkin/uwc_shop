class Comment < ActiveRecord::Base
  attr_accessible :title, :body, :product_id, :user_id
  belongs_to :user
  belongs_to :product
end
