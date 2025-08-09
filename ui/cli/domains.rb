# frozen_string_literal: true

require "sqlite3"

module Cli
  module Domains
    def self.main(args)
      if args.length < 2
        puts "Usage: tabs domains add <fqdn>"
        exit(EXITCODE_USAGE)
      end

      db_path = File.join(ROOT_DIR, "storage/tabs.db")
      db = SQLite3::Database.new(db_path)

      args[0]
      fqdn = args[1]

      begin
        puts Tabs::Domains::Commands.create!(db, fqdn)
      rescue Tabs::Errors::EntityExists
        puts "#{fqdn} already exists."
        exit(EXITCODE_ERROR)
      rescue Tabs::Errors::ValidationFailed
        puts "#{fqdn} is not a valid FQDN."
        exit(EXITCODE_ERROR)
      end
    end
  end
end
