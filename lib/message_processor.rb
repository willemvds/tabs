require "date"
require "json"

require_relative "domains"

class MessageProcessor
  def initialize(db)
    @started = false
    @db = db
  end

  def start()
    if @started
      return
    end

    config = {
      "bootstrap.servers": "localhost:9092",
      "group.id": "tabs-web",
    }
    consumer = Rdkafka::Config.new(config).consumer
    @consumer = consumer

    Thread.new {
      consumer.subscribe("https")
      consumer.each do |message|
        puts "Message received: #{message.inspect}"
        msg = JSON.parse(message.payload)
        process(msg)
      end
    }
  end

  def stop()
    if !@started
      return
    end

    @consumer.close
  end

  def process(msg)
    fqdn = msg.fetch("fqdn")
    cert = msg.fetch("cert")
    response = msg.fetch("response")
    fields = {
      ip: msg.fetch("ips")[0],
      is_online: response.fetch("code") == 200,
      cert_issuer: cert.fetch("issuer"),
      cert_subject: cert.fetch("subject"),
      cert_serial: cert.fetch("serial"),
      cert_not_before: DateTime.parse(cert.fetch("not_before")),
      cert_not_after: DateTime.parse(cert.fetch("not_after")),
      response_body_length: response.fetch("body_length"),
    }
    r = Domains::Commands.update_status!(@db, fqdn, fields)
  end
end
