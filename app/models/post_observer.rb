class PostObserver < ActiveRecord::Observer
  observe Forem::Post

  def after_save(post)
    users = [User.find(1), User.find(4)]

    users.each do |user|
      Notifier.new_post(post, user).deliver
    end
  end
end
