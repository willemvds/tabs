# frozen_string_literal: true

module Web
  class Style
    CSS_TEXT_GOOD = "good"
    CSS_TEXT_OKAY = "okay"
    CSS_TEXT_BAD = "bad"

    def self.ping_css_class(ping)
      return CSS_TEXT_GOOD if ping < 50
      return CSS_TEXT_OKAY if ping < 150

      CSS_TEXT_BAD
    end

    def self.expire_days_css_class(days)
      return CSS_TEXT_GOOD if days > 60
      return CSS_TEXT_OKAY if days > 30

      CSS_TEXT_BAD
    end

    def self.body_length_css_class(num_bytes)
      return CSS_TEXT_GOOD if num_bytes < 4 * 1024
      return CSS_TEXT_OKAY if num_bytes < 200 * 1024

      CSS_TEXT_BAD
    end

    def self.http_version_css_class(version)
      return CSS_TEXT_GOOD if version == "2"
      return CSS_TEXT_OKAY if version == "1.1"

      CSS_TEXT_BAD
    end
  end
end
