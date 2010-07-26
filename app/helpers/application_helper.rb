module ApplicationHelper
  def oauth_register_button(options = {})
    oauth_button('register_with_oauth', options)
  end

  def oauth_login_button(options = {})
    oauth_button('login_with_oauth', options)
  end

  def display_comments(commentable)
    render :partial => "shared/comments", :locals => {:commentable => commentable}
  end

  def w3c_date(date)
    date.utc.strftime("%Y-%m-%dT%H:%M:%S+00:00")
  end

  def tag_link(tag)
    link_to tag, sprites_path(:tagged => tag.to_s)
  end

  private
  def oauth_button(name, options = {})
    "<input type='submit' value='#{options[:value]}' name='#{name}' id='user_submit' class='#{options[:class]}'/>".html_safe
  end
end
