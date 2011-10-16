class Job
  @queue = :jobs

  def self.perform(id, class_name, method, *args)
    class_name.constantize.find(id).send method, *args
  end
end
