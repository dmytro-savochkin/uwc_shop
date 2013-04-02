class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :grouper, :menu

  def grouper
    category = Category.find_by_link params[:category_link]
    @groups_data, @product_ids = category.build_groups_data(params) if category
  end

  def menu
    @menu = Faction.all
  end
end
