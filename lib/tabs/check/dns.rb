# frozen_string_literal: true

module Tabs
  module Check
    module DNS
      def self.addresses(fqdn)
        resolver = Resolver.new(fqdn, dog: Dog, dig: Dig)
        resolver.ips
      end
    end
  end
end
