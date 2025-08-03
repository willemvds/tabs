# frozen_string_literal: true

require 'date'

module Tabs
  module Users
    class DuplicateUser < StandardError
    end

    module Commands
      def self.create!(db, created_by, username)
        create_user_query = "
      INSERT INTO
        users (
          username,
          is_active,
          created_by,
          created_at
        )
      VALUES
        (?, ?, ?, ?)
      "
        created_at = DateTime.now
        begin
          db.transaction
          db.execute(create_user_query, [
                       username,
                       User::ACTIVE,
                       created_by.id,
                       created_at.to_s
                     ])
          rows = db.execute('SELECT last_insert_rowid()')
          db.commit
        rescue SQLite3::ConstraintException
          db.rollback
          # puts e.code
          # puts e.message
          raise DuplicateUser
        rescue SQLite3::SQLException => e
          db.rollback
          raise e
        end

        User.new(
          rows[0][0],
          User::ACTIVE,
          username,
          created_by.id,
          created_at
        )
      end

      def self.create_tables!(db)
        create_users_query = "
      CREATE TABLE IF NOT EXISTS
        users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username VARCHAR(200) UNIQUE NOT NULL,
          is_active BOOLEAN NOT NULL,
          created_at DATETIME NOT NULL,
          created_by INTEGER NOT NULL
        )
      "

        db.execute create_users_query
      end
    end
  end
end
