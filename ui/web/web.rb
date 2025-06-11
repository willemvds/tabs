require "erb"

require "ougai"
require "rack"

require_relative "../../lib/domains"
require_relative "../../lib/users"

class Web
  def initialize(db_path)
    @logger = Ougai::Logger.new($stdout)
    @db_path = db_path
    @index_template = ERB.new(File.read("../ui/web/templates/index.rhtml"))

    db = SQLite3::Database.new(db_path)
    Users::Commands.create_tables!(db)
    Domains::Commands.create_tables!(db)
  end

  def call(env)
    req = Rack::Request.new(env)
    @logger.debug({
      msg: "Request Received",
      method: req.request_method,
      path: req.path_info,
    })

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
    statuses = Domains::Queries::most_recent_statuses(db)

    statuses.each do |status|
      @logger.debug({
        msg: "Domain Status",
        status: status.inspect(),
      })
    end

    ic = IndexContext.new(statuses)
    body = @index_template.result(ic.get_binding)
    [200, { "Content-Type": "text/html; charset=utf-8" }, [body]]
  end
end
