require "erb"

require "rack"

require_relative "../../lib/domains"
require_relative "../../lib/users"

class Web
  def initialize(db_path)
    @db_path = db_path
    @index_template = ERB.new(File.read("../ui/web/templates/index.rhtml"))

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

  class IndexContext
    attr_reader :domains

    def initialize(domains)
      @domains = domains
    end

    def get_binding()
      binding
    end
  end

  def index(req)
    db = SQLite3::Database.new(@db_path)
    s = Domains::Queries::most_recent_statuses(db)
    puts "s=#{s.inspect}"

    ic = IndexContext.new(s)
    body = @index_template.result(ic.get_binding)
    [200, { "Content-Type": "text/html; charset=utf-8" }, [body]]
  end
end
