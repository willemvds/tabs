# frozen_string_literal: true

module Tabs
  module Versions
    module Queries
      def self.version(db, relation)
        by_fqdn_query = <<-SQL
          SELECT
            version
          FROM
            versions
          WHERE
            relation=?
          ORDER BY
            created_at DESC
          LIMIT
            1
        SQL
        rows = db.execute(by_fqdn_query, relation)
        return 0 if rows.empty?

        rows[0][0]
      end
    end
  end
end
