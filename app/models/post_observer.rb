class PostObserver < ActiveRecord::Observer
  observe Forem::Post

  def after_save(post)
    users = post.topic.posts.map(&:user).uniq - [post.user]

    users.each do |user|
      Notifier.new_post(post, user).deliver if user.forum_notifications
    end
  end
  handle_asynchronously :after_save
end
