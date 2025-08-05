# frozen_string_literal: true

require 'open3'

module Dog
  DEFAULT_BINARY_PATH = 'dog'
  private_constant :DEFAULT_BINARY_PATH

  EXIT_CODE_NO_RESULTS = 2
  EXIT_CODE_INVALID_QUERY = 3
  private_constant :EXIT_CODE_NO_RESULTS
  private_constant :EXIT_CODE_INVALID_QUERY

  class BinaryUnavailable < StandardError
  end

  class InvalidFQDN < StandardError
  end

  class NoResults < StandardError
  end

  def self.ips(fqdn, binary_path = 'dog')
    begin
      stdout, stderr, status = Open3.capture3(binary_path, '-1', fqdn)
    rescue SystemCallError => e
      raise BinaryUnavailable, e
    end

    if status.success?
      ips = stdout.split
      return ips
    end

    raise InvalidFQDN if status.exitstatus == EXIT_CODE_INVALID_QUERY

    raise NoResults if status.exitstatus == EXIT_CODE_NO_RESULTS

    raise StandardError, "Unexpected dog error: exit code=#{status.exitstatus}, stderr=#{stderr}"
  end
end
