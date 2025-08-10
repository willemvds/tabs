# frozen_string_literal: true

module Tabs
  module Check
    module DNS
      class Resolver
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
          ips = @dog.ips(@fqdn)
          ok(ips)
        rescue Dog::Errors::InvalidFQDN
          err(Errors::InvalidFQDN.new)
        rescue Dog::Errors::NoResults
          err(Errors::NoRecordsFound.new)
        rescue Dog::Errors::Unexpected, Dog::Errors::BinaryUnavailable
          :has_dig
        end

        def resolve_using_dig
          ips = @dig.ips(@fqdn)
          ok(ips)
        rescue Dig::NoResults
          err(Errors::NoRecordsFound.new)
        rescue Dig::Error, Dig::BinaryUnavailable
          err(Errors::ServiceUnavailable.new)
        end
      end
    end
  end
end
