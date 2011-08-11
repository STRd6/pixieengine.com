class PostObserver < ActiveRecord::Observer
  observe Forem::Post

  def after_save(post)
    Notifier.new_post(post).deliver
  end
end