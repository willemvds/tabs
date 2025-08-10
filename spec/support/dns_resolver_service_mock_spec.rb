# frozen_string_literal: true

class DNSResolverServiceMock
  def ips(fqdn)
    unless @error.nil?
      raise @error
    end

    @ips
  end

  def self.returning_ips(ips)
    DNSResolverServiceMock.new(ips: ips)
  end

  def self.raising(error)
    DNSResolverServiceMock.new(error: error)
  end

  private

  def initialize(ips: [], error: nil)
    @ips = ips
    @error = error
  end
end
