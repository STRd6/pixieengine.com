module LinkHelper
  def avatar_link(user)
    link_to image_tag(user.avatar.url(:thumb), :alt => user.display_name, :class => :avatar), user
  end

  def button_link(text, icon, link, options={})
    link_to "#{image_tag "icons/#{icon}.png"} #{text}".html_safe, link, {:class => "button"}.merge(options)
  end

  def filter_link(text, filter, options={})
    active = filter.to_s == self.filter.to_s ? "active" : ""

    link_to text, { :filter => filter }, {:class => "button #{active}"}.merge(options)
  end

  def icon_link(text, icon, link, options={})
    link_to "#{icon_image(icon, text)} #{text}".html_safe, link, {:title => text, :class => "icon"}.merge(options)
  end

  def hint_link(text, link, options={})
    link_to hint_icon(text), link, {:class => "hint"}.merge(options)
  end
end
