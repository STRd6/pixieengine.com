module AsyncHandling
  def send_later(method, *args)
    Resque.enqueue(Job, id, self.class.name, method, *args)
  end

  module ClassMethods
    def handle_asynchronously(method)
      without_name = "#{method}_without_send_later"
      define_method("#{method}_with_send_later") do |*args|
        send_later(without_name, *args)
      end
      alias_method_chain method, :send_later
    end
  end
end

