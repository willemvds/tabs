# frozen_string_literal: true

#
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status
#
# Will all caps name when we figure out zeitwerk.
#
module Http
  # 2xx - Successful responses
  STATUS_OK = 200

  # 4xx - Client error responses
  STATUS_NOT_FOUND = 404

  # 5xx - Server error responses
  STATUS_INTERNAL_SERVER_ERROR = 500
end
