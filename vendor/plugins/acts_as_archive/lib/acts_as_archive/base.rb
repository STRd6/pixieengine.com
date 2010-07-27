module ActsAsArchive
  
  module Base
    module ActMethods
      def acts_as_archive(options={})
        class_eval <<-end_eval
          
          def self.acts_as_archive?
            self.to_s == #{self.to_s.inspect}
          end
          
          def self.archive_indexes
            #{Array(options[:indexes]).map{|index| index.is_a?(Array) ? index.map(&:to_sym) : index.to_sym}.inspect}
          end
          
          class Archive < ActiveRecord::Base
            self.record_timestamps = false
            self.table_name = "archived_#{self.table_name}"
          end
        end_eval
        include Destroy
        include Restore
        include Table
      end
    end
  end
end
