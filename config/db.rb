require 'sqlite3'

def init_database
  # Open a database
  db = SQLite3::Database.new 'messages.db'
  db.results_as_hash = true

  # Create a table
  db.execute <<-SQL
  create table if not exists messages (
    id integer primary key,
    user varchar(255),
    message text,
    created_at timestamp
  );
  SQL

  db
end
