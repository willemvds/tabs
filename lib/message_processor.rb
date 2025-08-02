# frozen_string_literal: true

require 'date'
require 'json'

require 'bunny'

class MessageProcessor
  def initialize(db)
    @started = false
    @db = db
  end

  def start
    return if @started

    @connection = Bunny.new
    @connection.start

    channel = @connection.create_channel
    queue_name = 'https'
    queue = channel.queue(queue_name, durable: true, arguments: { 'x-queue-type' => 'quorum' })

    Thread.new do
      queue.subscribe(block: true) do |_delivery_info, _properties, body|
        puts "delivery info #{_delivery_info}"
        puts "properties #{_properties}"
        puts "body #{body}"
        msg = JSON.parse(body)
        process(msg)
      end
    end
  end

  def stop
    return unless @started

    @consumer.close
  end

  def process(msg)
    fqdn = msg.fetch('fqdn')
    cert = msg.fetch('cert')
    response = msg.fetch('response')
    ips = msg.fetch('ips').sort!
    ip = ips.first
    fields = {
      ip: ip,
      is_online: response.fetch('code').to_i == 200,
      cert_issuer: cert.fetch('issuer'),
      cert_subject: cert.fetch('subject'),
      cert_serial: cert.fetch('serial'),
      cert_not_before: DateTime.parse(cert.fetch('not_before')),
      cert_not_after: DateTime.parse(cert.fetch('not_after')),
      response_body_length: response.fetch('body_length')
    }
    Domains::Commands.update_status!(@db, fqdn, fields)
  end
end
