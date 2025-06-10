require "rack"

require_relative "../../lib/domains"
require_relative "../../lib/users"

class Web
  def initialize(db_path)
    @db_path = db_path

    db = SQLite3::Database.new(db_path)
    Users::Commands.create_tables!(db)
    Domains::Commands.create_tables!(db)
  end

  def call(env)
    req = Rack::Request.new(env)
    puts "req=#{req.inspect}"

    case req.path_info
    when "/"
      index(req)
    else
      [404, {}, ["NOT FOUND"]]
    end
  end

  def index(req)
    db = SQLite3::Database.new(@db_path)
    s = Domains::Queries::most_recent_statuses(db)
    puts "s=#{s.inspect}"
    [200, {}, ["Hello, World"]]
  end
end
