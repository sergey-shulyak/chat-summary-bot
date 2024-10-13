# frozen_string_literal: true

require_relative 'init'

db = DB.new(ENV.fetch('DB_NAME'))
bot = Bot.new(ENV.fetch('TELEGRAM_BOT_API_TOKEN'), logger: Logger.new($stdout), db:)

Signal.trap('INT') do
  puts 'Stopping bot'
  bot.stop
  db.client.close
  exit(0)
end

bot.start
