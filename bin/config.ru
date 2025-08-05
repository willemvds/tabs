# frozen_string_literal: true

require_relative '../autoloader'

require 'sqlite3'

DEFAULT_QUEUE_NAME = 'https'
config = {
  queue_name: DEFAULT_QUEUE_NAME,
  db_path: File.join(ROOT_DIR, 'storage/tabs.db')
}

begin
  local_config = TomlRB.load_file(
    File.join(ROOT_DIR, 'storage/tabs.toml'), symbolize_keys: true
  )
  config.merge(local_config)
rescue StandardError
end

# DB_PATH = File.join(ROOT_DIR, 'storage/tabs.db')

begin
  db = SQLite3::Database.new(config[:db_path])
  mp = Tabs::MessageProcessor.new do |fqdn, updates|
    Tabs::Domains::Commands.update_status! db, fqdn, updates
  end
  mp.start

  run Web::Main.new(config)
rescue Interrupt => e
  puts "Interrupted #{e}"
  mp.stop
end
