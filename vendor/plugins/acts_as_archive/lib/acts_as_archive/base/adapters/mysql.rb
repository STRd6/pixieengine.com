module ActsAsArchive
  module Base
    module Adapters
      module MySQL
        
        private

        def archive_table_indexed_columns
          index_query = "SHOW INDEX FROM archived_#{table_name}"
          indexes = connection.select_all(index_query)
          final_indexes = []
          current_index = 0
          indexes.each do |index|
            if index['Seq_in_index'] != '1'
              final_indexes[current_index-1] = Array(final_indexes[current_index-1]).flatten.concat(Array(index['Column_name'].to_sym))
            else
              final_indexes[current_index] = index['Column_name'].to_sym
              current_index += 1
            end
          end
          return final_indexes
        end
      end
    end
  end
end
