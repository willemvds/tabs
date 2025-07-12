# frozen_string_literal: true

module Domains
  class Domain
    attr_reader :fqdn, :created_at

    def initialize(fqdn, created_at)
      @fqdn = fqdn
      @created_at = created_at
    end
  end
end
