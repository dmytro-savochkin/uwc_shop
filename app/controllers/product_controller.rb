class ProductController < ApplicationController
  def show
    product_id = params[:product_id]
    @product = Product.find(product_id)
  end
end
