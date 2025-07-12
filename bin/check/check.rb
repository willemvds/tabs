# frozen_string_literal: true

require 'date'
require 'json'
require 'net/http'
require 'openssl'
require 'uri'

require 'rdkafka'
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

kafka_config = { "bootstrap.servers": 'localhost:9092' }
producer = Rdkafka::Config.new(kafka_config).producer
delivery_handle = producer.produce(
  topic: 'https',
  payload: event_json,
  key: UUID7.generate
)
puts delivery_handle
hr = delivery_handle.wait
puts hr
