# frozen_string_literal: true

require 'sqlite3'
require 'zeitwerk'

require_relative '../autoloader'

DB_PATH = File.join(ROOT_DIR, 'storage/tabs.db')

begin
  db = SQLite3::Database.new(DB_PATH)
  mp = MessageProcessor.new(db)
  mp.start

  run Web::Main.new(DB_PATH)
rescue Interrupt => e
  puts "Interrupted #{e}"
  mp.stop
end
