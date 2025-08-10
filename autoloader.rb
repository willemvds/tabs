# frozen_string_literal: true

require "zeitwerk"

ROOT_DIR = File.dirname(__FILE__).freeze

loader = Zeitwerk::Loader.new

loader.inflector.inflect(
  "dns" => "DNS",
  "invalid_fqdn" => "InvalidFQDN",
  "http" => "HTTP",
  "rabbit_mq" => "RabbitMQ",
)

loader.push_dir(File.join(ROOT_DIR, "lib"))
loader.push_dir(File.join(ROOT_DIR, "ui"))

loader.setup
loader.eager_load
