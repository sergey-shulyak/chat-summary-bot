require 'sqlite3'

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
      create table if not exists messages (
        id integer primary key,
        user varchar(255),
        message text,
        chat_id integer,
        created_at timestamp
      );
    SQL

    db
  end
end
