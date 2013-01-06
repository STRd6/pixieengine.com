module Concerns
  module Reporting

    extend ActiveSupport::Concern

    # add your static(class) methods here
    module ClassMethods
      def new_per_week
        ActiveRecord::Base.connection.execute(self
          .select("COUNT(*) AS count, date_trunc('week', created_at) as date")
          .group("date")
          .order("date ASC")
          .where("created_at > ?", 6.months.ago)
          .to_sql
        )
      end
    end
  end
end
