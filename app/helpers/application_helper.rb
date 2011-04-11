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

  def button_link(text, icon, link, options={})
    link_to "#{image_tag "icons/#{icon}.png"} #{text}".html_safe, link, {:class => "button"}.merge(options)
  end

  def session_key_name
    Rails.application.config.session_options[:key]
  end

  def subscription_link(user)
    subscription_plan_id = 9356

    link_to "Subscribe", "https://spreedly.com/STRd6-test/subscribers/#{user.id}/subscribe/#{subscription_plan_id}/#{user.email}"
  end

  private
  def oauth_button(name, options = {})
    "<input type='submit' value='#{options[:value]}' name='#{name}' id='user_submit' class='#{options[:class]}'/>".html_safe
  end
end
