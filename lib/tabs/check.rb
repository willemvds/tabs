# frozen_string_literal: true

require "date"
require "net/http"
require "openssl"
require "uri"

module Tabs
  module Check
    class Bad < StandardError
    end

    def self.domain(fqdn)
      begin
        ips = Subprocess.check_output(["dog", "-1", fqdn]).split
      rescue Subprocess::NonZeroExit => e
        raise Bad, e.message
      rescue StandardError => e
        puts "dog err=#{e.message}"
        puts "falling back on dig..."
        begin
          ips = Subprocess.check_output(["dig", fqdn, "+short"]).split
        rescue StandardError => e
          puts "dig err=#{e.message}"
          raise Bad, e.message
        end
      end

      uri = URI("https://#{fqdn}/")

      event = {
        "fqdn": fqdn,
        "ips": ips,
        "uri": uri,
      }

      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        cert = OpenSSL::X509::Certificate.new(http.peer_cert)

        event = event.merge({
          "cert": {
            "subject": cert.subject,
            "issuer": cert.issuer,
            "serial": cert.serial,
            "not_before": cert.not_before,
            "not_after": cert.not_after,
          },
        })

        request = Net::HTTP::Get.new(uri)
        #  puts request
        request_started_at = DateTime.now
        body_length = 0
        response_code = 0
        response_message = ""
        http.request(request) do |response|
          #    puts response.inspect
          response.read_body do |chunk|
            #      puts "chunky #{chunk}"
            body_length += chunk.length
          end
          response_code = response.code
          response_message = response.message
        end
        request_completed_at = DateTime.now
        duration = request_completed_at - request_started_at
        duration_us = (duration * 24 * 60 * 60 * 1000 * 1000).to_i
        duration_ms = duration_us / 1000

        event = event.merge({
          "request": {
            "started_at": request_started_at,
            "completed_at": request_completed_at,
            "duration_us": duration_us,
            "duration_ms": duration_ms,
          },
          "response": {
            "code": response_code,
            "message": response_message,
            "body_length": body_length,
          },
        })
      end
    end
  end
end
