# frozen_string_literal: true

require 'sqlite3'

class Message
  attr_reader :user, :message, :date, :chat_id

  def self.messages_today(db:, chat_id:)
    db.execute('SELECT * FROM messages WHERE created_at > ? AND chat_id = ?',
               [Utils::TimeUtils.start_of_today, chat_id])
  end

  def self.messages_for_chat_empty?(db:, chat_id:)
    rows = db.execute('SELECT count(*) FROM messages WHERE chat_id = ?', [chat_id])
    rows[0]&.values[0]&.zero?
  end

  def initialize(user:, message:, date:, chat_id:, db:)
    @user = user
    @message = message
    @date = date
    @chat_id = chat_id
    @db = db
  end

  def save!
    @db.execute('INSERT INTO messages (user, message, chat_id, created_at) VALUES (?, ?, ?, ?)',
                [@user, @message, @chat_id, @date])
  end

  def destroy!
    @db.execute('DELETE FROM messages WHERE id = ?', [@id])
  end
end
