# frozen_string_literal: true

require "date"
require "net/http"
require "openssl"
require "uri"

module Tabs
  module Check
    def self.domain(fqdn)
      ips = DNS.addresses(fqdn)

      uri = URI("https://#{fqdn}/")

      event = {
        "fqdn": fqdn,
        "ips": ips,
        "uri": uri,
      }

      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        cert = OpenSSL::X509::Certificate.new(http.peer_cert)

        sans = []
        san_extension = cert.extensions.find { |ext| ext.oid == "subjectAltName" }
        if san_extension
          sans = san_extension.value.split(",").map(&:strip)
        end

        event = event.merge({
          "cert": {
            "subject": cert.subject,
            "issuer": cert.issuer,
            "serial": cert.serial,
            "not_before": cert.not_before,
            "not_after": cert.not_after,
            "sans": sans,
          },
        })

        request = Net::HTTP::Get.new(uri)
        #  puts request
        request_started_at = Time.now
        body_length = 0
        response_code = 0
        response_message = ""
        response_http_version = ""
        http.request(request) do |response|
          #    puts response.inspect
          response.read_body do |chunk|
            #      puts "chunky #{chunk}"
            body_length += chunk.length
          end
          response_code = response.code
          response_message = response.message
          response_http_version = response.http_version
        end
        request_completed_at = Time.now
        duration = request_completed_at - request_started_at
        duration_us = (duration * 1000 * 1000).floor
        duration_ms = (duration_us / 1000).round

        event = event.merge({
          "request": {
            "started_at": request_started_at,
            "completed_at": request_completed_at,
            "duration_us": duration_us,
            "duration_ms": duration_ms,
          },
          "response": {
            "http_version": response_http_version,
            "code": response_code,
            "message": response_message,
            "body_length": body_length,
          },
        })
      end
    end
  end
end
