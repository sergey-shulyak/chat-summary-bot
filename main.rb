# frozen_string_literal: true

require 'dotenv/load'
require 'telegram/bot'

require_relative 'lib/utils/utils'
require_relative 'lib/db'
require_relative 'lib/gpt_client'
require_relative 'lib/bot'

db = DB.new(ENV.fetch('DB_NAME'))
bot = Bot.new(ENV.fetch('TELEGRAM_BOT_API_TOKEN'), logger: Logger.new($stdout), db: db)

Signal.trap('INT') do
  puts 'Stopping bot'
  bot.stop
  db.client.close
  exit(0)
end

bot.start
