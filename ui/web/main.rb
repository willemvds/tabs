# frozen_string_literal: true

require "erb"

require "ougai"
require "rack"
require "sqlite3"

module Web
  class Main
    def initialize(config)
      @logger = Ougai::Logger.new($stdout)
      @db_path = config[:db_path]
      @index_template = ERB.new(File.read(File.join(File.dirname(__FILE__), "templates/index.rhtml")))

      @db = SQLite3::Database.new(@db_path)
      Tabs::Versions::Commands.create_tables!(@db)
      Tabs::Users::Commands.create_tables!(@db)
      Tabs::Domains::Migrations.migrate!(@db)
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
        [HTTP::STATUS_NOT_FOUND, {}, ["Not Found"]]
      end
    end

    class IndexContext
      attr_reader :domains

      def initialize(domains)
        @domains = domains
      end

      def get_binding
        binding
      end
    end

    def index(_req)
      @index_template = ERB.new(File.read(File.join(File.dirname(__FILE__), "templates/index.rhtml")))
      statuses = Tabs::Domains::Queries.most_recent_statuses(@db)

      statuses.each do |status|
        @logger.debug({
          msg: "Domain Status",
          status: status.inspect,
        })
      end

      ic = IndexContext.new(statuses)
      body = @index_template.result(ic.get_binding)
      [HTTP::STATUS_OK, { "Content-Type": "text/html; charset=utf-8" }, [body]]
    end
  end
end
