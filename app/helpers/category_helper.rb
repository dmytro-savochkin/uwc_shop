module CategoryHelper
  def group_value_checkbox(enabled, checked, link)
    build_checkbox_link(link)
    check_box_tag 'checkbox', 1, checked, :disabled => (not enabled),
                  :onclick => "location.href='" + build_checkbox_link(link) + "';"
  end

  def build_checkbox_link(link)
    '/category/' + params[:category_link] + '/?' + link
  end


end
