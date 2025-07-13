# frozen_string_literal: true

require 'sqlite3'

require_relative '../lib/message_processor'
require_relative '../ui/web'

DB_PATH = 'tabs.db'

begin
  db = SQLite3::Database.new(DB_PATH)
  mp = MessageProcessor.new(db)
  mp.start

  run Web.new(DB_PATH)
rescue Interrupt => e
  puts "Interrupted #{e}"
  mp.stop
end
