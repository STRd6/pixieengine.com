class PostObserver < ActiveRecord::Observer
  observe Forem::Post

  def after_save(post)
    daniel = User.find 1
    matt = User.find 4

    users = (post.topic.posts.map(&:user).uniq - [post.user] + [daniel, matt]).uniq

    users.each do |user|
      Notifier.new_post(post, user).deliver if user.forum_notifications
    end
  end
end
