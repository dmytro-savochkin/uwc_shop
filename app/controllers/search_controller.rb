class SearchController < ApplicationController
  def show
    q = params[:search]
    @products = Product.where("title LIKE '%#{q}%' OR short_description LIKE '%#{q}%'")
  end
end
