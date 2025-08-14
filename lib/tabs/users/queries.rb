# frozen_string_literal: true

require "date"

module Tabs
  module Users
    ROOT_ID = 1

    module Queries
      def self.all(db)
        all_query = "
        SELECT
          id,
          username,
          is_active,
          created_by,
          created_at
        FROM
          users
        ORDER BY
          id ASC
      "
        rows = db.execute(all_query)
        rows.map do |row|
          User.new(
            row[0],
            row[1],
            row[2],
            row[3],
            row[4],
          )
        end
      end

      def self.root
        User.new(
          ROOT_ID,
          "root",
          User::ACTIVE,
          Time.now,
          ROOT_ID,
        )
      end

      def self.by_id(db, id)
        by_id_query = "
        SELECT
          id,
          username,
          is_active,
          created_by,
          created_at
        FROM
          users
        WHERE
          id=?
        LIMIT
          1
      "

        rows = db.execute(by_id_query, id)
        raise Errors::NotFound if rows.empty?

        row = rows[0]
        User.new(
          row[0],
          row[1],
          row[2],
          row[3],
          row[4],
        )
      end
    end
  end
end
