# frozen_string_literal: true

require 'date'
require 'json'
require 'net/http'
require 'openssl'
require 'uri'

require 'bunny'
require 'subprocess'
require 'uuid7'

require_relative '../../lib/check'

EXIT_CODE_USAGE = 1
EXIT_CODE_FAILURE = 2

args = ARGV

if args.length != 1
  puts 'Usage: check <fqdn>'
  exit(EXIT_CODE_USAGE)
end

fqdn = args[0]

begin
  event = Check.domain fqdn
rescue Check::Bad => e
  puts "check domain err=#{e.message}"
  exit(EXIT_CODE_FAILURE)
end

event_json = JSON.generate(event)
puts event_json

connection = Bunny.new
connection.start
channel = connection.create_channel
queue_name = 'https'
queue = channel.queue(queue_name, durable: true, arguments: { 'x-queue-type' => 'quorum' })
puts channel.default_exchange.publish(event_json, routing_key: queue.name)
