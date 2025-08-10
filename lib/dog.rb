# frozen_string_literal: true

require "open3"

module Dog
  DEFAULT_BINARY_PATH = "dog"
  private_constant :DEFAULT_BINARY_PATH

  EXITCODE_NO_RESULTS = 2
  EXITCODE_INVALID_QUERY = 3

  def self.ips(fqdn, binary_path = "dog")
    begin
      stdout, stderr, status = Open3.capture3(binary_path, "-1", fqdn)
    rescue SystemCallError => e
      raise Errors::BinaryUnavailable, e
    end

    if status.success?
      ips = stdout.split
      return ips
    end

    raise Errors::InvalidFQDN if status.exitstatus == EXITCODE_INVALID_QUERY

    raise Errors::NoResults if status.exitstatus == EXITCODE_NO_RESULTS

    raise Errors::Unexpected, "Unexpected dog error: exit code=#{status.exitstatus}, stderr=#{stderr}"
  end
end
