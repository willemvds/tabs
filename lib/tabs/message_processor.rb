# frozen_string_literal: true

require 'date'
require 'json'

require 'bunny'

module Tabs
  class MessageProcessor
    def initialize(&process_block)
      @process_block = process_block
      @started = false
    end

    def start
      return if @started

      @connection = Bunny.new
      @connection.start

      channel = @connection.create_channel
      queue_name = 'https'
      queue = channel.queue(queue_name,
                            durable: true,
                            arguments: { RabbitMq::QUEUE_TYPE_KEY => RabbitMq::QUEUE_TYPE_QUORUM })

      Thread.new do
        queue.subscribe(manual_ack: true, block: true) do |delivery_info, _properties, body|
          puts "delivery info #{delivery_info}"
          puts "properties #{_properties}"
          puts "body #{body}"
          msg = JSON.parse(body, symbolize_names: true)
          process(msg)
          channel.acknowledge(delivery_info.delivery_tag, false)
        end
      end
    end

    def stop
      return unless @started

      @consumer.close
    end

    def process(msg)
      fqdn = msg.fetch(:fqdn)
      cert = msg.fetch(:cert)
      response = msg.fetch(:response)
      ips = msg.fetch(:ips).sort!
      ip = ips.first
      fields = {
        ip: ip,
        is_online: response.fetch(:code).to_i == Http::STATUS_OK,
        cert_issuer: cert.fetch(:issuer),
        cert_subject: cert.fetch(:subject),
        cert_serial: cert.fetch(:serial),
        cert_not_before: DateTime.parse(cert.fetch(:not_before)),
        cert_not_after: DateTime.parse(cert.fetch(:not_after)),
        response_body_length: response.fetch(:body_length)
      }
      @process_block.call(fqdn, fields)
    end
  end
end
