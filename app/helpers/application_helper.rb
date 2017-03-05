module ApplicationHelper
  def author_link(item)
    render partial: "shared/attribution", locals: {
      creator: item.user,
      anonym: "Anonymous",
    }
  end

  def card_attribution(item)
    render partial: "shared/card_attribution", locals: {
      creator: item.user,
    }
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

  def tag_link(tag)
    link_to tag, action: :index, tagged: tag
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
