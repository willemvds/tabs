# frozen_string_literal: true

module Tabs
  module Errors
    class NotFound < StandardError
    end

    class EntityExists < StandardError
    end

    class ValidationFailed < StandardError
    end
  end
end
