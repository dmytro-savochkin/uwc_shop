module ApplicationHelper
  def product_link(product)
    '/' + product[:category_link].to_s + '/' + product[:link].to_s + '/' + product[:id].to_s
  end

  def category_link(category_link)
    '/category/'+category_link
  end
end
