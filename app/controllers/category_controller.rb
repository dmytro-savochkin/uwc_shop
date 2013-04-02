class CategoryController < ApplicationController
  def show
    @category = Category.find_by_link params[:category_link]
    @products = Product.find_all_by_id(@product_ids)
  end


end
