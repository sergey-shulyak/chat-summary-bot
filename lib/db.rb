# frozen_string_literal: true

class DB
  attr_reader :client

  def initialize(db_name)
    @db_name = db_name
    @client = init_database(db_name)
  end

  def cleanup!(chat_id)
    @client.execute('DELETE FROM messages WHERE created_at < ? AND chat_id = ?', [Time.now.to_i, chat_id])
  end

  def clean_all!
    @client.execute('DELETE FROM messages WHERE created_at < ?', [Time.now.to_i])
  end

  def close
    @client.close
  end

  private

  def init_database(db_name)
    db = SQLite3::Database.new "#{db_name}.db"
    db.results_as_hash = true

    # Create a table
    db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS messages (
        id INTEGER PRIMARY KEY,
        user VARCHAR(255),
        message TEXT,
        chat_id INTEGER,
        created_at TIMESTAMP
      );
    SQL

    db
  end
end
