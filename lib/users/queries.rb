require "date"

require_relative "../errors"

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
      users = rows.map do |row|
        User.new(
          row[0],
          row[1],
          row[2],
          row[3],
          row[4],
        )
      end
    end

    def self.root()
      user = User.new(
        ROOT_ID,
        "root",
        User::ACTIVE,
        DateTime.now(),
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
      if rows.length == 0
        raise Errors::NotFound.new
      end

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
