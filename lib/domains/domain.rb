module Domains
  class Domain
    attr_reader :fqdn
    attr_reader :created_at

    def initialize(fqdn, created_at)
      @fqdn = fqdn
      @created_at = created_at
    end
  end
end
