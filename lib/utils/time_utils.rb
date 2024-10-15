# frozen_string_literal: true

module TimeUtils
  def self.start_of_today
    now = Time.now
    start_of_day = Time.new(now.year, now.month, now.day)
    start_of_day.to_i
  end
end
