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

  def icon_image(icon, text=nil)
    "#{image_tag "icons/#{icon}.png", :alt => text}".html_safe
  end

  def hint_icon(text)
    "#{image_tag "icons/help.png", :alt => text, :class => :tipsy, :title => text}".html_safe
  end

  def session_key_name
    Rails.application.config.session_options[:key]
  end

  def display_gallery(collection, filters)
    render :partial => "shared/gallery", :locals => {:collection => collection, :filters => filters}
  end

  private
  def oauth_button(name, options = {})
    "<input type='submit' value='#{options[:value]}' name='#{name}' id='user_submit' class='#{options[:class]}'/>".html_safe
  end
end
