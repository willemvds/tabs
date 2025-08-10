# frozen_string_literal: true

require "timeout"

module Tabs
  module Check
    module DNS
      class Resolver
        DEFAULT_TIMEOUT_SECONDS = 5

        def initialize(fqdn, dog: nil, dig: nil)
          if dog.nil? && dig.nil?
            raise Errors::ResolverServiceRequired
          end

          @fqdn = fqdn
          @dog = dog
          @dig = dig
        end

        def ips
          state = :has_dog
          state = send(state) while state

          @ips
        end

        private

        def ok(ips)
          @ips = ips
          nil
        end

        def err(error)
          raise error
        end

        def has_dog
          return :resolve_using_dog unless @dog.nil?

          :has_dig
        end

        def has_dig
          return :resolve_using_dig unless @dig.nil?

          err(Errors::ServiceUnavailable.new)
        end

        def resolve_using_dog
          Timeout.timeout(DEFAULT_TIMEOUT_SECONDS) do
            ips = @dog.ips(@fqdn)
            ok(ips)
          end
        rescue Timeout::Error
          :has_dig
        rescue Dog::InvalidFQDN
          err(Errors::InvalidFQDN.new)
        rescue Dog::NoResults
          err(Errors::NoRecordsFound.new)
        rescue Dog::Error, Dog::BinaryUnavailable
          :has_dig
        end

        def resolve_using_dig
          Timeout.timeout(DEFAULT_TIMEOUT_SECONDS) do
            ips = @dig.ips(@fqdn)
            ok(ips)
          end
        rescue Timeout::Error
          err(Errors::ServiceUnavailable.new)
        rescue Dig::NoResults
          err(Errors::NoRecordsFound.new)
        rescue Dig::Error, Dig::BinaryUnavailable
          err(Errors::ServiceUnavailable.new)
        end
      end
    end
  end
end
