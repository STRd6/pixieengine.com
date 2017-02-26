module ApplicationHelper
  def author_link(item)
    user = item.user

    "By #{user ? link_to(user, user) : 'Anonymous'}".html_safe
  end

  def avatar_link(user)
    link_to image_tag(user.avatar.url(:thumb), alt: user.display_name), user, class: :avatar
  end

  def markdown(text)
    return "" unless text

    renderOptions = {hard_wrap: true, filter_html: true}
    markdownOptions = {autolink: true, no_intra_emphasis: true}
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(renderOptions), markdownOptions)
    markdown.render(text).html_safe
  end

  def sprite_tag_link(sprite, tag)
    render :partial => "sprites/tag", :object => tag, :locals => {:sprite => sprite}
  end

  def display_comments(commentable)
    render :partial => "shared/comments", :locals => {:commentable => commentable}
  end

  def following?(user)
    if current_user
      current_user.following?(user)
    end
  end

  def pagination_for(collection)
    will_paginate collection, {
      inner_window: 2,
      outer_window: 0,
    }
  end
end
