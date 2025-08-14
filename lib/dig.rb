# frozen_string_literal: true

require "open3"

module Dig
  DEFAULT_BINARY_PATH = "dig"
  private_constant :DEFAULT_BINARY_PATH

  class Error < StandardError
  end

  class BinaryUnavailable < Error
  end

  class NoResults < Error
  end

  def self.ips(fqdn, binary_path = DEFAULT_BINARY_PATH)
    begin
      stdout, stderr, status = Open3.capture3(binary_path, fqdn, "+short")
    rescue SystemCallError => e
      raise BinaryUnavailable, e
    end

    raise Error, "Unexpected dig error: exit code=#{status.exitstatus}, stderr=#{stderr}" unless status.success?

    ips = stdout.split

    raise NoResults if ips.empty?

    ips
  end
end
