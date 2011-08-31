class Require
  class Dsl < Array
    
    def all(*values)
      if values.empty?
        self
      else
        Dsl.new(self.select { |a| a[0..values.length-1] == values })
      end
    end
    
    def call(&block)
      instance_eval(&block) if block_given?
      self
    end
    
    def get(*values)
      self.detect { |a| a[0..values.length-1] == values }
    end
    
    def gem(*args, &block)
      args.unshift(:gem)
      method_missing *args, &block
    end
    
    def method_missing(*args, &block)
      if args.length == 1 && a = self.get(args[0])
        a[1]
      else
        if block_given?
          args << Dsl.new.call(&block)
        end
        self << Args.new(args)
      end
    end
    
    def require(*args, &block)
      args.unshift(:require)
      method_missing *args, &block
    end
    
    class Args < Array
      
      def all(*values)
        dsl.all(*values) if dsl
      end
      
      def dsl
        self[-1] if self[-1].class == Require::Dsl::Args || self[-1].class == Dsl
      end
      
      def get(*values)
        dsl.get(*values) if dsl
      end
      
      def gem?
        self[0] == :gem
      end
      
      def load_path?
        self[0] == :load_path
      end
      
      def name
        self[1] if gem? && self[1] != dsl
      end
      
      def path
        self[1] if (require? || load_path?) && self[1] != dsl
      end
      
      def require?
        self[0] == :require
      end
      
      def version
        self[2] if self[0] == :gem && self[2] != dsl
      end
    end
  end
end
