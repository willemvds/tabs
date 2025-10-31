# frozen_string_literal: true

require "date"

class TimeFormat
  def self.days_until(t)
    now = Time.new
    days_diff = (t - now) / (24 * 60 * 60)
    days_diff.floor
  end
end
