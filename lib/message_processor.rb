# frozen_string_literal: true

require 'date'
require 'json'

require_relative 'domains'

class MessageProcessor
  def initialize(db)
    @started = false
    @db = db
  end

  def start
    return if @started

    # msg = JSON.parse(message.payload)
    # process(msg)
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
