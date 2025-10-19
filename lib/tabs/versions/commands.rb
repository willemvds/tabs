# frozen_string_literal: true

module Tabs
  module Versions
    module Commands
      def self.create_tables!(db)
        create_users_query = <<-SQL
          CREATE TABLE IF NOT EXISTS
            versions (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              relation VARCHAR(200) NOT NULL,
              version INTEGER NOT NULL,
              created_at DATETIME NOT NULL
            )
        SQL

        db.execute(create_users_query)
      end

      def self.set!(db, relation, version)
        set_version_query = <<-SQL
          INSERT INTO
            versions (relation, version, created_at)
          VALUES
            (?, ?, ?)
        SQL

        created_at = Time.now.to_s
        db.execute(set_version_query, [relation, version, created_at])
      end
    end
  end
end
