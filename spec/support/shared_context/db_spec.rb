# frozen_string_literal: true

require "fileutils"
require "securerandom"
require "sqlite3"

RSpec.shared_context("db") do
  # TODO(@willemvds): Make the test suite build a fresh db on start and then just copy the file for each test.
  before do
    random_hex_name = SecureRandom.hex(20)
    @test_db_path = File.join(File.dirname(__FILE__), "#{random_hex_name}.db")
    test_db = SQLite3::Database.new(@test_db_path)

    Tabs::Users::Commands.create_tables!(test_db)
    Tabs::Domains::Commands.create_tables!(test_db)

    @test_db = test_db
  end

  after do
    FileUtils.rm(@test_db_path)
  end
end
