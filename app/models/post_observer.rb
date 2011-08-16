class PostObserver < ActiveRecord::Observer
  observe Forem::Post

  def after_save(post)
    User.find(1, 4).each do |user|
      Notifier.new_post(post, user).deliver
    end
  end
  handle_asynchronously :after_save
end
