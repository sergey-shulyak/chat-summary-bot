# frozen_string_literal: true

require 'dotenv/load'
require 'telegram/bot'
require 'debug'

require_relative 'config/db'
require_relative 'lib/gpt_client'
require_relative 'lib/bot'

db = init_database

bot = Bot.new(ENV['TELEGRAM_BOT_API_TOKEN'], logger: Logger.new($stdout), db:)

Signal.trap('INT') do
  puts 'Stopping bot'
  bot.stop
end

bot.start
