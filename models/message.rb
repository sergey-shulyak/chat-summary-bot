# frozen_string_literal: true

require 'sqlite3'

class Message
  def self.cleanup(db)
    db.execute('DELETE FROM messages WHERE created_at < ?', [Time.now.to_i])
  end

  def self.messages_today(db)
    db.execute('SELECT * FROM messages WHERE created_at > ?', [start_of_today])
  end

  def self.start_of_today
    now = Time.now

    start_of_day = Time.new(now.year, now.month, now.day)

    start_of_day.to_i
  end

  def initialize(user, message, date, db:)
    @db = db
    @user = user
    @message = message
    @date = date
  end

  def save!
    @db.execute('INSERT INTO messages (user, message, created_at) VALUES (?, ?, ?)', [@user, @message, @date])
  end
end
