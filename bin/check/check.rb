# frozen_string_literal: true

require_relative "../../autoloader"

require "date"
require "json"
require "net/http"
require "openssl"
require "uri"

require "bunny"
require "subprocess"
require "toml-rb"
require "uuid7"

EXIT_CODE_USAGE = 1
EXIT_CODE_FAILURE = 2

args = ARGV
if args.length != 1
  puts "Usage: check <domain.lst>"
  exit(EXIT_CODE_USAGE)
end

DEFAULT_QUEUE_NAME = "https"
config = {
  queue_name: DEFAULT_QUEUE_NAME,
}

begin
  local_config = TomlRB.load_file(
    File.join(ROOT_DIR, "bin/check/check.toml"), symbolize_keys: true
  )
  config.merge(local_config)
rescue StandardError # rubocop:disable Lint/SuppressedException
  # This is an optional step - it is allowed to fail silently.
end

domains_path = args[0]
domains = File.read(domains_path).split
domains = domains.select { |domain| domain.length > 0 }

connection = Bunny.new
connection.start
channel = connection.create_channel
queue_name = "https"
queue = channel.queue(
  queue_name,
  durable: true,
  arguments: { RabbitMQ::QUEUE_TYPE_KEY => RabbitMQ::QUEUE_TYPE_QUORUM },
)

domains.each do |fqdn|
  begin
    event = Tabs::Check.domain(fqdn)
  rescue StandardError => e
    puts "check domain=#{fqdn} err=#{e.message}"
  end

  event_json = JSON.generate(event)
  puts event_json

  puts channel.default_exchange.publish(event_json, routing_key: queue.name)
end
