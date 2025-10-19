# frozen_string_literal: true

module Tabs
  module Domains
    class Status
      ONLINE = 1
      OFFLINE = 0

      attr_reader :fqdn,
        :ip,
        :cert_issuer,
        :cert_subject,
        :cert_serial,
        :cert_not_before,
        :cert_not_after,
        :cert_sans,
        :response_body_length,
        :created_at

      def initialize(fqdn, args)
        @fqdn = fqdn
        @ip = args.fetch(:ip)
        @is_online = args.fetch(:is_online)
        @cert_issuer = args.fetch(:cert_issuer)
        @cert_subject = args.fetch(:cert_subject)
        @cert_serial = args.fetch(:cert_serial)
        @cert_not_before = args.fetch(:cert_not_before)
        @cert_not_after = args.fetch(:cert_not_after)
        @cert_sans = args.fetch(:cert_sans)
        @response_body_length = args.fetch(:response_body_length)
        @created_at = args.fetch(:created_at)
      end

      def online?
        @is_online
      end
    end
  end
end
